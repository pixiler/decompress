===========================================================================
 ZSTD Decompress - Vitis HLS tasinabilir proje
===========================================================================

AMAC
  Xilinx Vitis_libraries icindeki zstd_decompress tasarimini, kutuphanenin
  tamamina ihtiyac duymadan baska bir PC'de calistirmak icin gereken TUM
  kaynak/header dosyalari bu klasore kopyalandi.

GEREKSINIM
  - Vitis HLS 2023.1 (2023.1.1)
  - Hedef parca: xcku5p-ffvb676-2-e  (Kintex UltraScale+, lisanssiz/WebPACK)
    Farkli parcaya gececeksen tcl icindeki 'set_part' satirini degistir.

KLASOR YAPISI
  run_l1_zstd.tcl       -> FAZ 1: fonksiyonel dogrulama (csim/csynth/cosim)
  run_l2_zstd_ip.tcl    -> FAZ 2: Vivado IP uretimi (csynth + export_design)
  src/
    data_compression/
      L1/include/hw/                 HLS cekirdek headerlari
      L1/tests/zstd_decompress/      test bench + ornek veri (sample.txt[.zst])
      L2/include/                    L2 stream kernel headerlari
      L2/src/zstd_decompress_stream.cpp   IP top kaynagi
      common/libs/logger/            logger (test bench yardimcisi)
      common/libs/cmdparser/         komut satiri ayiristirici (test bench)
    security/
      L1/include/xf_security/        checksum (adler32/crc32) headerlari

NASIL CALISTIRILIR (yeni PC'de)
  1) Bu klasoru src/ ile BIRLIKTE butun halinde kopyala.
  2) "Vitis HLS 2023.1 Command Prompt" ac, bu klasore gir:
        cd /d <bu klasorun tam yolu>
     ONEMLI: farkli surucudeysen (orn. tool D:'de, proje E:'de) '/d' SART.
     Duz 'cd' cmd.exe'de surucu degistirmez -> script bulunamaz.
  3) Dogrulama icin:   vitis_hls -f run_l1_zstd.tcl
     IP uretimi icin:  vitis_hls -f run_l2_zstd_ip.tcl
  Yollar script konumuna gore otomatik cozulur (info script); elle
  duzenleme gerekmez. Projeler calistigin dizinde olusur.

ONEMLI NOTLAR
  - HeadeR'lar URAM -> BRAM olacak sekilde DEGISTIRILMISTIR
    (zstd_fse_decoder.hpp: bitStream, lz_decompress.hpp: ramHistory).
    Sebep: hedef sistemde URAM bosta degil, cozucu tamamen BRAM kullaniyor.
    URAM'e geri donmek istersen bu iki dosyadaki 'impl = bram/BRAM' ->
    'impl = uram/URAM' yap.
  - Pencere/blok boyutu 32 KB (ZSTD_BLOCK_SIZE_KB=32). Gercek .zst dosyan
    daha buyuk pencere (wlog) ile sikistirildiysa donanim penceresini de
    buyut: L1'de zstd_decompress_test.cpp icindeki ZSTD_BLOCK_SIZE_KB /
    WINDOW_SIZE; L2'de tcl icindeki -D ZSTD_BLOCK_SIZE_KB=... degerini
    esitle. Kural: donanim penceresi >= sikistirma penceresi.
  - Clock 9 ns (~111 MHz). period 8'de HLS slack sinirda negatifti (-0.17).

IP CIKTISI (FAZ 2 sonrasi)
  zstd_l2_ip/sol1/impl/ip/xilinx_com_hls_xilZstdDecompressStream_1_0.zip
  Vivado'da: Settings > IP > Repository ile bu klasoru/zip'i ekle, sonra
  block design'a "xilZstdDecompressStream" IP'sini koy.
  Portlar: ap_clk, ap_rst_n, inaxistreamd (AXIS 32b slave),
           outaxistreamd (AXIS 64b master), ap_ctrl_none (free-running).
===========================================================================
