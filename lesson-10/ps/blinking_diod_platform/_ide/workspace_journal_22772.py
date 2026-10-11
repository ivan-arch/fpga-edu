# 2026-10-11T14:49:38.178119
import vitis

client = vitis.create_client()
client.set_workspace(path="blinking_diod_platform")

platform = client.get_component(name="blinking_diod_platform")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../blinking_diod/design_1_wrapper.xsa")

status = platform.build()

status = platform.build()

status = platform.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../blinking_diod/design_1_wrapper.xsa")

status = platform.build()

status = platform.build()

domain = platform.get_domain(name="zynq_fsbl")

status = domain.set_config(option = "lib", param = "XILTIMER_sleep_timer", value = "ps7_scutimer_0", lib_name="xiltimer")

domain = platform.get_domain(name="standalone_ps7_cortexa9_0")

status = domain.set_config(option = "lib", param = "XILTIMER_sleep_timer", value = "ps7_scutimer_0", lib_name="xiltimer")

status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

comp = client.get_component(name="app_component")
status = comp.update_platform(platform="$COMPONENT_LOCATION/../blinking_diod_platform/export/blinking_diod_platform/blinking_diod_platform.xpfm")

comp = client.get_component(name="app_component")
comp.build()

status = comp.clean()

comp.build()

status = comp.clean()

comp = client.get_component(name="app_component")
status = comp.update_platform(platform="$COMPONENT_LOCATION/../../../../../blinking_diod_platform/blinking_diod_platform/export/blinking_diod_platform/blinking_diod_platform.xpfm")

comp = client.get_component(name="app_component")
comp.build()

client.delete_component(name="app_component")

status = client.add_platform_repos(platform=["c:\work\edu\my\FPGA\lesson-10\ps\blinking_diod_platform"])

status = client.add_platform_repos(platform=["/c:/work/edu/my/blinking_diod_platform/blinking_diod_platform/export/blinking_diod_platform"])

comp = client.create_app_component(name="app_component",platform = "$COMPONENT_LOCATION/../../../../../blinking_diod_platform/blinking_diod_platform/export/blinking_diod_platform/blinking_diod_platform.xpfm",domain = "standalone_ps7_cortexa9_0")

comp.build()

comp.build()

comp.build()

vitis.dispose()

