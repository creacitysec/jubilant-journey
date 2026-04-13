FROM runpod/worker-comfyui:5.8.5-base

# ── Impact Pack + Subpack ──
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    cd ComfyUI-Impact-Pack && \
    pip install --no-cache-dir -r requirements.txt

RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git

RUN pip install --no-cache-dir ultralytics

# ── Ultimate SD Upscale ──
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git --recursive

# ── SUPIR (kijai) ──
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-SUPIR.git && \
    cd ComfyUI-SUPIR && pip install --no-cache-dir -r requirements.txt

# ── KJNodes ──
RUN comfy-node-install comfyui-kjnodes

# ── Provision script ──
COPY provision_image.sh /provision_image.sh
RUN chmod +x /provision_image.sh

CMD ["/provision_image.sh"]
