FROM runpod/worker-comfyui:5.8.5-base

# ── Custom nodes ──
# Impact Pack (Face Detailer, Person Detailer)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    cd ComfyUI-Impact-Pack && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack impact_subpack && \
    pip install -r requirements.txt 2>/dev/null || true

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
