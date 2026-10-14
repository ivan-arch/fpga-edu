# 2026-10-14T13:00:52.319635
import vitis

client = vitis.create_client()
client.set_workspace(path="moving_max")

cfg = client.get_config_file(path="C:\work\edu\my\FPGA\lesson-15\moving_max\hls_component\hls_config.cfg")

cfg.set_values(key="syn.file", values=["moving_max.cpp", "moving_max.h"])

comp = client.get_component(name="hls_component")
comp.run(operation="SYNTHESIS")

comp.run(operation="SYNTHESIS")

cfg = client.get_config_file(path="/c:/work/edu/my/FPGA/lesson-15/moving_max/hls_component/hls_config.cfg")

cfg.set_value(section="hls", key="syn.top", value="moving_max")

comp.run(operation="SYNTHESIS")

cfg = client.get_config_file(path="C:\work\edu\my\FPGA\lesson-15\moving_max\hls_component\hls_config.cfg")

cfg.set_values(key="syn.file", values=["moving_max.c", "moving_max.h"])

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

cfg.set_values(key="syn.file", values=["moving_max.cpp", "moving_max.h"])

cfg.set_values(key="tb.file", values=["moving_max_tb.cpp"])

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="SYNTHESIS")

comp.run(operation="SYNTHESIS")

cfg = client.get_config_file(path="/c:/work/edu/my/FPGA/lesson-15/moving_max/hls_component/hls_config.cfg")

cfg.set_value(section="hls", key="syn.compile.enable_auto_rewind", value="0")

cfg.set_value(section="hls", key="syn.compile.pipeline_loops", value="0")

comp.run(operation="SYNTHESIS")

comp.run(operation="SYNTHESIS")

comp.run(operation="SYNTHESIS")

comp.run(operation="CO_SIMULATION")

comp.run(operation="PACKAGE")

vitis.dispose()

