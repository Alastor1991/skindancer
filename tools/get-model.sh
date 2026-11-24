#!/bin/sh
# Downloads the optional SigLIP2 model for search by meaning (~410 MB) from Hugging Face
# (onnx-community/siglip2-base-patch16-224-ONNX, Apache-2.0) into ~/.local/share/oboi/models/siglip2.
# Without it, Skindancer searches by titles, tags and file names.
set -eu
D=${OBOI_MODEL:-${XDG_DATA_HOME:-$HOME/.local/share}/oboi/models/siglip2}
U=https://huggingface.co/onnx-community/siglip2-base-patch16-224-ONNX/resolve/main
mkdir -p "$D"
for f in onnx/vision_model_quantized.onnx onnx/text_model_quantized.onnx tokenizer.json tokenizer_config.json \
         special_tokens_map.json preprocessor_config.json config.json; do
    echo "downloading $f"
    curl -fL --retry 3 -o "$D/$(basename "$f").part" "$U/$f"
    mv "$D/$(basename "$f").part" "$D/$(basename "$f")"
done
(cd "$D" && sha256sum vision_model_quantized.onnx text_model_quantized.onnx > SHA256SUMS)
echo "done: $D"
