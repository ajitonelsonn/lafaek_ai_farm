"""Train a MobileNetV3-Small crop-condition classifier and export to TFLite.

Classes come from the sub-folders of ./data. Preprocessing (0-255 float RGB
-> MobileNetV3 scaling) is baked INTO the model via include_preprocessing=True,
so the app only needs to resize to 224x224 and feed float32 pixel values.
"""
import json, os, sys, time
import numpy as np
import tensorflow as tf

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(ROOT, 'data')
OUT = os.path.join(ROOT, 'out')
os.makedirs(OUT, exist_ok=True)
IMG = 224
BATCH = 32
SEED = 7
EPOCHS_HEAD = int(os.environ.get('EPOCHS_HEAD', 4))
EPOCHS_FT = int(os.environ.get('EPOCHS_FT', 3))

train_ds = tf.keras.utils.image_dataset_from_directory(
    DATA, validation_split=0.15, subset='training', seed=SEED,
    image_size=(IMG, IMG), batch_size=BATCH, label_mode='categorical')
val_ds = tf.keras.utils.image_dataset_from_directory(
    DATA, validation_split=0.15, subset='validation', seed=SEED,
    image_size=(IMG, IMG), batch_size=BATCH, label_mode='categorical')
class_names = train_ds.class_names
print('classes', class_names)

# Strong augmentation: maize/tomato (PlantVillage) and rice come from
# different sources, so the model must not key on background or colour
# balance. Random crops, colour jitter and occasional grayscale force it to
# use leaf texture instead.
def _jitter(x):
    x = tf.image.random_saturation(x, 0.5, 1.6)
    x = tf.image.random_hue(x, 0.05)
    # 15% of samples go grayscale (3-channel) to break colour shortcuts.
    gray = tf.tile(tf.image.rgb_to_grayscale(x), [1, 1, 1, 3])
    pick = tf.cast(tf.random.uniform([tf.shape(x)[0], 1, 1, 1]) < 0.15, x.dtype)
    return pick * gray + (1 - pick) * x


aug = tf.keras.Sequential([
    tf.keras.layers.RandomFlip('horizontal_and_vertical'),
    tf.keras.layers.RandomRotation(0.25),
    tf.keras.layers.RandomTranslation(0.12, 0.12),
    tf.keras.layers.RandomZoom(0.3, 0.3),
    tf.keras.layers.RandomContrast(0.35),
    tf.keras.layers.RandomBrightness(0.25, value_range=(0, 255)),
    tf.keras.layers.Lambda(_jitter),
    tf.keras.layers.Lambda(lambda x: tf.clip_by_value(x, 0.0, 255.0)),
])
AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.map(lambda x, y: (aug(x, training=True), y), num_parallel_calls=AUTOTUNE).prefetch(AUTOTUNE)
val_ds = val_ds.prefetch(AUTOTUNE)

base = tf.keras.applications.MobileNetV3Small(
    input_shape=(IMG, IMG, 3), include_top=False, weights='imagenet',
    include_preprocessing=True, minimalistic=False)
base.trainable = False
inputs = tf.keras.Input(shape=(IMG, IMG, 3), name='image')
x = base(inputs, training=False)
x = tf.keras.layers.GlobalAveragePooling2D()(x)
x = tf.keras.layers.Dropout(0.25)(x)
outputs = tf.keras.layers.Dense(len(class_names), activation='softmax', name='probs')(x)
model = tf.keras.Model(inputs, outputs)

# Label smoothing curbs the over-confident wrong answers we saw on
# out-of-distribution photos.
loss_fn = tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.05)
model.compile(optimizer=tf.keras.optimizers.Adam(1e-3), loss=loss_fn, metrics=['accuracy'])
t0 = time.time()
model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS_HEAD)

# Fine-tune the top of the backbone.
base.trainable = True
for layer in base.layers[:-40]:
    layer.trainable = False
model.compile(optimizer=tf.keras.optimizers.Adam(1e-4), loss=loss_fn, metrics=['accuracy'])
model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS_FT)
val_loss, acc = model.evaluate(val_ds)
print('val accuracy %.4f  (train time %.0fs)' % (acc, time.time() - t0))

# Per-class validation accuracy for the model card.
y_true, y_pred = [], []
for xb, yb in val_ds:
    y_true.extend(np.argmax(yb.numpy(), axis=1).tolist())
    y_pred.extend(np.argmax(model.predict(xb, verbose=0), axis=1).tolist())
y_true, y_pred = np.array(y_true), np.array(y_pred)
per_class = {c: float((y_pred[y_true == i] == i).mean()) for i, c in enumerate(class_names)}
print('per-class', per_class)

# Export: float32 TFLite (fast enough on CPU, no calibration needed).
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tfl = converter.convert()
path = os.path.join(OUT, 'crop_condition_mnv3s.tflite')
open(path, 'wb').write(tfl)
open(os.path.join(OUT, 'labels.txt'), 'w').write('\n'.join(class_names) + '\n')
meta = {
    'name': 'crop_condition_mnv3s',
    'architecture': 'MobileNetV3-Small (ImageNet backbone, fine-tuned)',
    'version': '1.1.0-dev',
    'input': {'width': IMG, 'height': IMG, 'channels': 3, 'dtype': 'float32',
              'range': '0-255 RGB (scaling is inside the model)'},
    'output': {'classes': class_names, 'activation': 'softmax'},
    'training_data': "PlantVillage (CC0) maize + tomato subset; rice from minhhungg/rice-disease-dataset (Apache-2.0); plus an 'other' class of non-leaf crops generated from the app's own imagery",
    'train_images': int(sum(1 for _ in train_ds.unbatch())),
    'val_accuracy': float(acc),
    'per_class_val_accuracy': per_class,
    'quantization': 'float16 weights',
    'file_size_bytes': len(tfl),
    'status': 'development — lab images only, not field-validated in Timor-Leste',
    'notes': ('Maize/tomato and rice come from different source datasets, so cross-dataset '
              'generalisation to field photos is unverified. Treat every output as a possible '
              'finding, never a confirmed diagnosis.'),
}
json.dump(meta, open(os.path.join(OUT, 'model_meta.json'), 'w'), indent=2)
print('wrote', path, len(tfl), 'bytes')

# Sanity check the TFLite file with the interpreter.
interp = tf.lite.Interpreter(model_path=path)
interp.allocate_tensors()
print('tflite input', interp.get_input_details()[0]['shape'], interp.get_input_details()[0]['dtype'])
print('tflite output', interp.get_output_details()[0]['shape'])
