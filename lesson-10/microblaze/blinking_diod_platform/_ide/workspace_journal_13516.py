# 2026-10-07T15:20:35.829710900
import vitis

client = vitis.create_client()
client.set_workspace(path="blinking_diod_platform")

platform = client.create_platform_component(name = "blinking_diod_platform",hw_design = "$COMPONENT_LOCATION/../../blinking_diod/design_1_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

platform = client.get_component(name="blinking_diod_platform")
status = platform.build()

comp = client.create_app_component(name="app_component",platform = "$COMPONENT_LOCATION/../blinking_diod_platform/export/blinking_diod_platform/blinking_diod_platform.xpfm",domain = "standalone_ps7_cortexa9_0")

comp = client.get_component(name="app_component")
comp.build()

comp.build()

comp.build()

comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../blinking_diod/design_1_wrapper.xsa")

status = platform.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

vitis.dispose()

