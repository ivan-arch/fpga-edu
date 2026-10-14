# 2026-10-13T16:38:39.105269500
import vitis

client = vitis.create_client()
client.set_workspace(path="moving_max")

comp = client.create_hls_component(name = "hls_component",cfg_file = ["hls_config.cfg"],template = "empty_hls_component")

comp = client.create_hls_component(name = "hls_component",part = "xc7z010clg400-1",cfg_file = ["hls_config.cfg"],template = "empty_hls_component")

cfg = client.get_config_file(path="C:\work\edu\my\FPGA\lesson-15\moving_max\hls_component\hls_config.cfg")

cfg.set_values(key="syn.file", values=["moving_max.c"])

cfg.set_values(key="syn.file", values=["moving_max.c", "moving_max.h"])

cfg.set_values(key="tb.file", values=["moving_max_tb.c"])

