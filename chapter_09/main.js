let model = null;
let imageProcessor = null;
let IMAGENET_CLASSES = [];

async function loadImagenetClasses() {
  // TODO: get the classes from Keggle instead. This may require authentication
  IMAGENET_CLASSES = await fetch(
    "https://raw.githubusercontent.com/anishathalye/imagenet-simple-labels/refs/heads/master/imagenet-simple-labels.json",
  ).then((response) => response.json());
}

// Initialize TensorFlow.js and load MobileNet model
async function initTensorFlow() {
  // Enable WebGL backend
  await tf.setBackend("webgl");
  console.log("Using backend:", tf.getBackend());

  // Get WebGl context information
  // "webgl2" context is the WebGL2.0 context for enhanced 3D rendering
  const gl = document.createElement("canvas").getContext("webgl2");
  // This should confirm that TensorFlow.js uses GPU and not CPU and
  // tell us which GPU is being used
  console.log("WebGL Vendor", gl.getParameter(gl.VENDOR));
  console.log("WebGL Renderer", gl.getParameter(gl.RENDERER));

  // Load pre-trained MobileNet model
  // ModileNet is a lightweight convolutional model designed for computer vision tasks
  // It is pre-trained on the ImageNet dataset to recognize 100 different object categories
  model = await tf.loadLayersModel(
    "https://storage.googleapis.com/tfjs-models/tfjs/mobilenet_v1_0.25_224/model.json",
  );
  console.log("Model loaded successfully");
}

function updateGPUIndicator(value) {
  const progressBar = document.getElementById("gpuProgress");
  progressBar.style.width = `${value}%`;
  progressBar.setAttribute("aria-valuenow", value);
}

// process image using WebAssembly and run inference
async function processImage(file) {
  const img = document.getElementById("imagePreview");
  const output = document.getElementById("output");

  // Display selected image
  img.src = URL.createObjectURL(file);

  // Wait for image too load
  await new Promise((resolve) => (img.onload = resolve));

  // Start GPU utilization indication
  updateGPUIndicator(50);

  // Convert image to tensor and warm up GPU:
  // 1. Each image's RGB values are extracted
  // 2. The image is resized to the dimensions the model expects
  // 3. An extra dimension is added for the batch size (expandDims)
  // 4. Values are converted and normalized to 0-1 range
  // 5. The result is a 4D tensor with shape [1, 224, 224, 3]
  // i.e. [batch_size, image_dimensions, RGB color channels]
  const startTime = performance.now();

  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d");
  canvas.width = img.width;
  canvas.height = img.height;
  ctx.drawImage(img, 0, 0);
  const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);

  // Create Uint8Array from image data
  const imageArray = new Uint8Array(imageData.data);

  // Call WebAssembly function for normalization
  const vector = new Module.VectorUChar();
  // Push each byte into the vector
  for (let i = 0; i < imageArray.length; i++) {
    vector.push_back(imageArray[i]);
  }
  // Now call the function with the vector
  const normalizedVector = Module.normalizeImage(vector);
  // Convert the result back to a JavaScript array
  const normalizedData = [];
  for (let i = 0; i < normalizedVector.size(); i++) {
    normalizedData.push(normalizedVector.get(i));
  }
  // Don't forget to clean up to prevent memory leaks
  vector.delete();
  normalizedVector.delete();

  // Use TensorFlow.js for resizing and analysis
  const tensor = tf.tidy(() => {
    return tf
      .tensor(normalizedData, [img.height, img.width, 4]) // Assuming RGBA data
      .slice([0, 0, 0], [img.height, img.width, 3]) // Remmove alpha channel if needed
      .resizeBilinear([224, 224])
      .expandDims();
  });
  // Comment/delete lines 64-98, and uncomment the code below
  // to see predict score increase, but at the expsense of
  // no longer using WebAssembly
  // const tensor = tf.tidy(() => {
  //   // Create multiple tensors to ensure GPU engagement
  //   const warmup = tf.zeros([1, 224, 224, 3]);
  //   const inputTensor = tf.browser
  //     .fromPixels(img)
  //     .resizeBilinear([224, 224])
  //     .expandDims()
  //     .toFloat()
  //     .div(255.0);
  //
  //   return inputTensor;
  // });

  updateGPUIndicator(75);
  let predictions;
  // can we use a more "functional" API for running this five times?
  for (let i = 0; i < 5; i++) {
    predictions = await model.predict(tensor).data();
  }

  const endTime = performance.now();
  console.log(`Inference time: ${endTime - startTime}ms`);

  const top5Predictions = Array.from(predictions)
    .map((prob, i) => ({ probability: prob, className: IMAGENET_CLASSES[i] }))
    .sort((a, b) => b.probability - a.probability)
    .slice(0, 5);

  // Display results with Bootstrap styling
  output.innerHTML = top5Predictions
    .map(
      (p) =>
        `<div class="alert alert-info">
      ${p.className}: ${(p.probability * 100).toFixed(2)}%
  </div>`,
    )
    .join("");

  // Clean up
  tensor.dispose();
  updateGPUIndicator(100);

  // Reset progress ba after 3 seconds
  setTimeout(() => updateGPUIndicator(0), 3000);
}

// Initialize eveything when page loads
window.onload = async () => {
  try {
    await initTensorFlow();
    await loadImagenetClasses();

    // Set up file input handler
    document.getElementById("imageInput").addEventListener("change", (e) => {
      // Don't we need a conole.log for the `else` clause?
      if (e.target.files[0]) {
        processImage(e.target.files[0]);
      } else {
        console.log("No files selected");
      }
    });
  } catch (error) {
    console.log("Initialization error:", error);
  }
};
