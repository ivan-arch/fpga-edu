# 2026-10-08T20:56:44.314053300
import vitis

client = vitis.create_client()
client.set_workspace(path="frame_capture_platform")

platform = client.create_platform_component(name = "frame_capture_platform",hw_design = "$COMPONENT_LOCATION/../../frame_capture/design_1_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

platform = client.get_component(name="frame_capture_platform")
status = platform.build()

comp = client.create_app_component(name="app_component",platform = "$COMPONENT_LOCATION/../frame_capture_platform/export/frame_capture_platform/frame_capture_platform.xpfm",domain = "standalone_microblaze_0")

comp = client.get_component(name="app_component")
status = comp.import_files(from_loc="C:\Users\ivanv\Downloads", files=["frame_capture.c"], dest_dir_in_cmp = "src", is_skip_copy_sources = False)

comp = client.get_component(name="app_component")
comp.build()

comp.build()

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../frame_capture/design_1_wrapper.xsa")

status = platform.build()

comp.build()

component = client.get_component(name="app_component")

lscript = component.get_ld_script(path="C:\work\edu\my\FPGA\lesson-12\frame_capture_platform\app_component\src\lscript.ld")

lscript.regenerate()

comp.build()

vitis.dispose()

vitis.dispose()

