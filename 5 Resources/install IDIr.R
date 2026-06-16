
# install openxlsx2
if(!"openxlsx2" %in% installed.packages()){
  install.packages("openxlsx2")
}

# uninstall IDIr
if("IDIr" %in% installed.packages()){
  remove.packages("IDIr", lib="~/R/x86_64-pc-linux-gnu-library/4.4")
}

# (re)installed IDIr
package_path = rstudioapi::selectFile(caption = "Select R package", filter = "Packages (*.gz)")

if(!is.null(package_path) && file.exists(package_path)){
  install.packages(package_path, repos = NULL, type = "source")
}
