# ============================================================
# FAZ 1 - L1 ZSTD decompress dogrulama (TASINABILIR surum)
# Baska bir PC'de:
#   1) Bu klasoru (src/ ile BIRLIKTE) butun halinde kopyala.
#   2) "Vitis HLS 2023.1 Command Prompt"tan bu klasore gir (surucu farkliysa /d SART):
#        cd /d <bu klasorun yolu>
#   3) vitis_hls -f run_l1_zstd.tcl
# Yollar script konumuna gore otomatik cozulur; elle duzenleme YOK.
# ============================================================

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set XF_PROJ_ROOT "${SCRIPT_DIR}/src/data_compression"
set DESIGN_PATH  "${XF_PROJ_ROOT}/L1/tests/zstd_decompress"

open_project -reset zstd_l1_decompress
set_top decompressFrame

# ---- Kaynak (sentezlenecek) dosyalar ----
add_files ${XF_PROJ_ROOT}/common/libs/logger/logger.cpp \
  -cflags "-I${XF_PROJ_ROOT}/common/libs/logger"
add_files ${XF_PROJ_ROOT}/common/libs/cmdparser/cmdlineparser.cpp \
  -cflags "-I${XF_PROJ_ROOT}/common/libs/cmdparser -I${XF_PROJ_ROOT}/common/libs/logger -I${XF_PROJ_ROOT}/../security/L1/include"
add_files ${DESIGN_PATH}/zstd_decompress_test.cpp \
  -cflags "-I${XF_PROJ_ROOT}/L1/include/hw -I${XF_PROJ_ROOT}/L2/include -I${XF_PROJ_ROOT}/common/libs/cmdparser -I${XF_PROJ_ROOT}/common/libs/logger -I${XF_PROJ_ROOT}/../security/L1/include"

# ---- Test bench (-tb) ----
add_files -tb ${XF_PROJ_ROOT}/common/libs/logger/logger.cpp \
  -cflags "-I${XF_PROJ_ROOT}/common/libs/logger"
add_files -tb ${XF_PROJ_ROOT}/common/libs/cmdparser/cmdlineparser.cpp \
  -cflags "-I${XF_PROJ_ROOT}/common/libs/cmdparser -I${XF_PROJ_ROOT}/common/libs/logger -I${XF_PROJ_ROOT}/../security/L1/include"
add_files -tb ${DESIGN_PATH}/zstd_decompress_test.cpp \
  -cflags "-I${XF_PROJ_ROOT}/L1/include/hw -I${XF_PROJ_ROOT}/L2/include -I${XF_PROJ_ROOT}/common/libs/cmdparser -I${XF_PROJ_ROOT}/../security/L1/include"

open_solution -reset sol1
set_part {xcku5p-ffvb676-2-e}
create_clock -period 9

# ============================================================
# FARKLI wlog (pencere) DEGERLERI ILE DENEMEK ISTERSEN:
#   L1'de pencere bu tcl'den DEGIL, test dosyasindaki iki #define'dan gelir:
#     ${DESIGN_PATH}/zstd_decompress_test.cpp
#   Su iki satiri esitle (ikisi de ayni boyutu gostermeli):
#     #define ZSTD_BLOCK_SIZE_KB 32     -> istedigin KB
#     #define WINDOW_SIZE (32 * 1024)   -> (istedigin_KB * 1024)
#   wlog <-> boyut:  13=8KB  14=16KB  15=32KB  16=64KB  17=128KB
#
#   KURAL: buradaki donanim penceresi >= .zst'nin sikistirma penceresi olmali,
#          yoksa cozum bozulur.
#
#   GERCEKTEN test etmek icin (kucuk ornek yerine kendi verinle):
#     1) Veriyi o wlog ile sikistir (ornek 64 KB = wlog 16):
#          python zstd_compress_to_bin.py data.bin -o data.zst -l 22 --window-log 16
#     2) Asagidaki csim/cosim satirlarinda -f (sikistirilmis) ve -o (orijinal)
#        yollarini kendi dosyalarina cevir:
#          -f <data.zst yolu>   -o <orijinal data.bin yolu>
#   NOT: Mevcut sample.txt.zst cok kucuk (tek segment); donanim penceresini
#        buyutmek onu bozmaz ama BUYUK pencereyi de gercekten sinamaz.
# ============================================================

csim_design   -argv "-f ${DESIGN_PATH}/sample.txt.zst -o ${DESIGN_PATH}/sample.txt"
csynth_design
cosim_design  -disable_dependency_check -argv "-f ${DESIGN_PATH}/sample.txt.zst -o ${DESIGN_PATH}/sample.txt"
exit
