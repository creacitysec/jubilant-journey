FROM runpod/worker-comfyui:5.8.5-base

# ── Custom nodes ──
# Impact Pack (Face Detailer, Person Detailer) + Subpack (UltralyticsDetectorProvider)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    cd ComfyUI-Impact-Pack && \
    pip install -r requirements.txt && \
    python install.py

RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git && \
    cd ComfyUI-Impact-Subpack && \
    (pip install -r requirements.txt 2>/dev/null || true) && \
    (python install.py 2>/dev/null || true)

# Ultralytics for face/person detection
RUN pip install ultralytics

# Ultimate SD Upscale
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git --recursive

# SUPIR upscale (kijai)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-SUPIR.git && \
    cd ComfyUI-SUPIR && pip install -r requirements.txt 2>/dev/null || true

# KJNodes (utility nodes)
RUN comfy-node-install comfyui-kjnodes

# ── Provision script ──
COPY provision_image.sh /provision_image.sh
RUN chmod +x /provision_image.sh

CMD ["/provision_image.sh"]
