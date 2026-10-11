# 2026-10-07T21:45:19.343311400
import vitis

client = vitis.create_client()
client.set_workspace(path="blinking_diod_platform")

platform = client.get_component(name="blinking_diod_platform")
status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../../blinking_diod/design_1_wrapper.xsa")

status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

component = client.get_component(name="app_component")

lscript = component.get_ld_script(path="C:\work\edu\my\FPGA\lesson-12\blinking_diod_platform\app_component\src\lscript.ld")

lscript.update_ld_section(".text", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".note.gnu.build-id", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".init", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".fini", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".rodata", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".rodata1", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".sdata2", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".sbss2", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".data", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".data1", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".got", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".ctors", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".dtors", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".fixup", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".eh_frame", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".eh_framehdr", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".gcc_except_table", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".mmu_tbl", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".ARM.exidx", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".preinit_array", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".init_array", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".fini_array", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".drvcfg_sec", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".ARM.attributes", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".sdata", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".sbss", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".tdata", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".tbss", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".bss", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".heap", "ps7_ddr_0_memory_0")

lscript.update_ld_section(".stack", "ps7_ddr_0_memory_0")

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

comp.build()

vitis.dispose()

vitis.dispose()

