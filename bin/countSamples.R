suppressPackageStartupMessages({
    require(readxl);
    require(dplyr);
    require(fs);
})

nc=read_xlsx(dir_ls(regex="^[^~].*___COUNTS.xlsx")) %>% ncol
cat(nc-4,"\n")
