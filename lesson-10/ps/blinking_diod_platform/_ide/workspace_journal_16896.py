# 2026-10-11T14:40:21.882425200
import vitis

client = vitis.create_client()
client.set_workspace(path="blinking_diod_platform")

comp = client.get_component(name="app_component")
comp.build()

platform = client.get_component(name="blinking_diod_platform")
status = platform.build()

comp.build()

vitis.dispose()

