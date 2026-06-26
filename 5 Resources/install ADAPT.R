
# uninstall IDIr
if("IDIr" %in% installed.packages()){
  remove.packages("IDIr")
}
# uninstall ADAPT
if("ADAPT" %in% installed.packages()){
  remove.packages("ADAPT")
}

# (re)installed IDIr
package_path = rstudioapi::selectFile(caption = "Select R package", filter = "Packages (*.gz)")

if(!is.null(package_path) && file.exists(package_path)){
  install.packages(package_path, repos = NULL, type = "source")
}
