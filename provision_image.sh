#!/bin/bash
set -e

VOL="/runpod-volume"
MODELS="$VOL/models"
MARKER="$MODELS/.cyberrealistic_pony_ready"

# ── Download models to network volume on first cold start ──
if [ -d "$VOL" ] && [ ! -f "$MARKER" ]; then
    echo "[provision] First start — downloading CyberRealisticPony pipeline models..."
    mkdir -p "$MODELS/checkpoints" "$MODELS/upscale_models" "$MODELS/ultralytics/bbox" "$MODELS/ultralytics/segm"

    # CyberRealisticPony v17 (~7GB)
    (wget -q --show-progress -O "$MODELS/checkpoints/cyberrealisticPony_v170.safetensors" \
        "https://civitai.com/api/download/models/2727742" \
        && echo "[provision] CyberRealisticPony v17 done") &

    # SUPIR-v0Q fp16 (~2.7GB) — quality-oriented restoration
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
    echo "[provision] All models ready on volume."
fi

# ── Symlink volume models into ComfyUI model dirs ──
if [ -d "$MODELS" ]; then
    for DIR in checkpoints upscale_models; do
        if [ -d "$MODELS/$DIR" ]; then
            mkdir -p "/comfyui/models/$DIR"
            ln -sf "$MODELS/$DIR"/* "/comfyui/models/$DIR/" 2>/dev/null || true
        fi
    done
    # Ultralytics models for Impact Pack
    if [ -d "$MODELS/ultralytics" ]; then
        mkdir -p "/comfyui/models/ultralytics/bbox" "/comfyui/models/ultralytics/segm"
        ln -sf "$MODELS/ultralytics/bbox"/* "/comfyui/models/ultralytics/bbox/" 2>/dev/null || true
        ln -sf "$MODELS/ultralytics/segm"/* "/comfyui/models/ultralytics/segm/" 2>/dev/null || true
    fi
    echo "[provision] Volume models symlinked into /comfyui/models/"
fi

# ── Hand off to original worker startup ──
exec /start.sh
