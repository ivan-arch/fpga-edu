# 2026-10-07T21:05:49.395761400
import vitis

client = vitis.create_client()
client.set_workspace(path="blinking_diod_platform")

component = client.get_component(name="app_component")

lscript = component.get_ld_script(path="C:\work\edu\my\FPGA\lesson-12\blinking_diod_platform\app_component\src\lscript.ld")

lscript.add_memory_region("new_memory_0", "0x0000", "0x8000")

comp = client.get_component(name="app_component")
comp.build()

lscript.update_ld_section(".text", "ps7_ram_0_memory_0")

lscript.update_ld_section(".note.gnu.build-id", "ps7_ram_0_memory_0")

lscript.update_ld_section(".init", "ps7_ram_0_memory_0")

lscript.update_ld_section(".fini", "ps7_ram_0_memory_0")

lscript.update_ld_section(".rodata", "ps7_ram_0_memory_0")

lscript.update_ld_section(".rodata1", "ps7_ram_0_memory_0")

lscript.update_ld_section(".sdata2", "ps7_ram_0_memory_0")

lscript.update_ld_section(".sbss2", "ps7_ram_0_memory_0")

lscript.update_ld_section(".data", "ps7_ram_0_memory_0")

lscript.update_ld_section(".data1", "ps7_ram_0_memory_0")

lscript.update_ld_section(".got", "ps7_ram_0_memory_0")

lscript.update_ld_section(".ctors", "ps7_ram_0_memory_0")

lscript.update_ld_section(".dtors", "ps7_ram_0_memory_0")

lscript.update_ld_section(".fixup", "ps7_ram_0_memory_0")

lscript.update_ld_section(".eh_frame", "ps7_ram_0_memory_0")

lscript.update_ld_section(".eh_framehdr", "ps7_ram_0_memory_0")

lscript.update_ld_section(".gcc_except_table", "ps7_ram_0_memory_0")

lscript.update_ld_section(".mmu_tbl", "ps7_ram_0_memory_0")

lscript.update_ld_section(".ARM.exidx", "ps7_ram_0_memory_0")

lscript.update_ld_section(".preinit_array", "ps7_ram_0_memory_0")

lscript.update_ld_section(".init_array", "ps7_ram_0_memory_0")

lscript.update_ld_section(".fini_array", "ps7_ram_0_memory_0")

lscript.update_ld_section(".drvcfg_sec", "ps7_ram_0_memory_0")

lscript.update_ld_section(".ARM.attributes", "ps7_ram_0_memory_0")

lscript.update_ld_section(".sdata", "ps7_ram_0_memory_0")

lscript.update_ld_section(".sbss", "ps7_ram_0_memory_0")

lscript.update_ld_section(".tdata", "ps7_ram_0_memory_0")

lscript.update_ld_section(".tbss", "ps7_ram_0_memory_0")

lscript.update_ld_section(".bss", "ps7_ram_0_memory_0")

lscript.update_ld_section(".heap", "ps7_ram_0_memory_0")

lscript.update_ld_section(".stack", "ps7_ram_0_memory_0")

comp.build()

comp.build()

vitis.dispose()

