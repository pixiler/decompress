# ============================================================
# FAZ 2 - L2 kernelinden Vivado IP uretme (TASINABILIR surum)
# Baska bir PC'de (surucu farkliysa /d SART):
#   cd /d <bu klasorun yolu>
#   vitis_hls -f run_l2_zstd_ip.tcl
# Cikti IP: zstd_l2_ip/sol1/impl/ip/  (.zip Vivado IP paketi)
# Yollar script konumuna gore otomatik cozulur; elle duzenleme YOK.
# ============================================================

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set XF_PROJ_ROOT "${SCRIPT_DIR}/src/data_compression"

open_project -reset zstd_l2_ip
set_top xilZstdDecompressStream

# L2 kernel kaynagi + ZORUNLU tanimlar (-D) + security include yolu
add_files ${XF_PROJ_ROOT}/L2/src/zstd_decompress_stream.cpp \
  -cflags "-I${XF_PROJ_ROOT}/L1/include/hw -I${XF_PROJ_ROOT}/L2/include -I${XF_PROJ_ROOT}/../security/L1/include \
           -DINPUT_BYTES=4 -DOUTPUT_BYTES=8 -DZSTD_BLOCK_SIZE_KB=64 -DFREE_RUNNING_KERNEL"
# NOT: ZSTD_BLOCK_SIZE_KB=64 -> 64 KB pencere (wlog 16). Bu IP, penceresi <=64 KB
# olan tum .zst'leri acar. Daha buyuk (wlog 17) icin 128 yap; BRAM ~2x artar.

open_solution -reset sol1
set_part {xcku5p-ffvb676-2-e}
create_clock -period 9

csynth_design
export_design -flow syn -rtl verilog -format ip_catalog
exit
