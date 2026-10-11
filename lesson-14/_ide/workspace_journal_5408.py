# 2026-10-10T22:23:40.249555400
import vitis

client = vitis.create_client()
client.set_workspace(path="lesson-14")

platform = client.get_component(name="platform")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../counter/design_1_wrapper.xsa")

status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

