BASELIB <- "3.5.0"
if(!file.exists(sprintf("../windows/baselibs-%s/include/png.h", BASELIB))){
  if(getRversion() < "3.3.0") setInternet2()
  download.file(sprintf("https://github.com/rwinlib/baselibs/archive/v%s.zip", BASELIB), "lib.zip", quiet = TRUE)
  dir.create("../windows", showWarnings = FALSE)
  unzip("lib.zip", exdir = "../windows")
  unlink("lib.zip")
}
