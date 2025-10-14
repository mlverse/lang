unnused_tags <- function(pkg) {
  db <- tools::Rd_db(pkg)
  topics <- fs::path_ext_remove(names(db))
  tags <- c(
    "\\title", "\\description", "\\value",
    "\\details", "\\seealso", "\\note", "\\author",
    "\\section", "\\arguments", "\\examples", 
    "\\name", "\\alias", "\\keyword", "\\usage",
    "\\references"
  )
  for(topic in db) {
    all_tags <- as.character(lapply(topic, function(x) attr(x, "Rd_tag")))
    dif <- setdiff(all_tags, tags)
    if(length(dif) != 0) {
      print(paste(as.character(topic[[2]]), "-", paste(dif, collapse = ", ")))
    }
  }  
}

unnused_tags("ggplot2")
unnused_tags("base")
unnused_tags("stats")