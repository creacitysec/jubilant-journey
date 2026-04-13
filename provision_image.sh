#!/bin/bash
set -e

VOL="/runpod-volume"
COMFY="/comfyui/models"

# Decide where to store models: network volume if available, else local ComfyUI
if [ -d "$VOL" ]; then
    MODELS="$VOL/models"
    MARKER="$MODELS/.cyberrealistic_pony_ready"
else
    MODELS="$COMFY"
    MARKER="$COMFY/.cyberrealistic_pony_ready"
fi

# ── Download models if not yet present ──
if [ ! -f "$MARKER" ]; then
    echo "[provision] Downloading CyberRealisticPony pipeline models to $MODELS ..."
    mkdir -p "$MODELS/checkpoints" "$MODELS/upscale_models" "$MODELS/ultralytics/bbox" "$MODELS/ultralytics/segm"

    # CyberRealisticPony v17 (~7GB)
    (wget -q --show-progress -O "$MODELS/checkpoints/cyberrealisticPony_v170.safetensors" \
        "https://civitai.com/api/download/models/2727742" \
        && echo "[provision] CyberRealisticPony v17 done") &

    # SUPIR-v0Q fp16 (~2.7GB)
    (wget -q --show-progress -O "$MODELS/checkpoints/SUPIR-v0Q_fp16.safetensors" \
        "https://huggingface.co/Kijai/SUPIR_pruned/resolve/main/SUPIR-v0Q_fp16.safetensors" \
        && echo "[provision] SUPIR-v0Q done") &

    # 4x-UltraSharp upscaler (~67MB)
    (wget -q --show-progress -O "$MODELS/upscale_models/4x-UltraSharp.pth" \
        "https://huggingface.co/Kim2091/UltraSharp/resolve/main/4x-UltraSharp.pth" \
        && echo "[provision] 4x-UltraSharp done") &

    # Ultralytics face detection for Impact Pack
    (wget -q --show-progress -O "$MODELS/ultralytics/bbox/face_yolov8m.pt" \
        "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
        && echo "[provision] face_yolov8m done") &

    # Ultralytics person segmentation for Impact Pack
    (wget -q --show-progress -O "$MODELS/ultralytics/segm/person_yolov8m-seg.pt" \
        "https://huggingface.co/Bingsu/adetailer/resolve/main/person_yolov8m-seg.pt" \
        && echo "[provision] person_yolov8m-seg done") &

    wait
    touch "$MARKER"
    echo "[provision] All models ready."
fi

# ── Symlink volume models into ComfyUI (only needed when using volume) ──
if [ -d "$VOL" ] && [ -d "$MODELS" ]; then
    for DIR in checkpoints upscale_models; do
        if [ -d "$MODELS/$DIR" ]; then
            mkdir -p "$COMFY/$DIR"
            ln -sf "$MODELS/$DIR"/* "$COMFY/$DIR/" 2>/dev/null || true
        fi
    done
    if [ -d "$MODELS/ultralytics" ]; then
        mkdir -p "$COMFY/ultralytics/bbox" "$COMFY/ultralytics/segm"
        ln -sf "$MODELS/ultralytics/bbox"/* "$COMFY/ultralytics/bbox/" 2>/dev/null || true
        ln -sf "$MODELS/ultralytics/segm"/* "$COMFY/ultralytics/segm/" 2>/dev/null || true
    fi
    echo "[provision] Volume models symlinked into $COMFY/"
fi

exec /start.sh
