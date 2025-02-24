#include <emscripten/bind.h>
#include <emscripten/val.h>
#include <vector>

using namespace emscripten;

// Function to normalize pixel values to [0, 1] range
std::vector<float> normalizeImage(const std::vector<unsigned char> &imageData) {
  std::vector<float> normalized;
  normalized.reserve(imageData.size());

  for (unsigned char pixel : imageData) {
    normalized.push_back(static_cast<float>(pixel) / 255.0f);
  }

  return normalized;
}

EMSCRIPTEN_BINDINGS(module) {
  register_vector<unsigned char>("VectorUChar");
  register_vector<float>("VectorFloat");

  function("normalizeImage", &normalizeImage);
}
