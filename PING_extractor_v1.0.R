# Copyright 2016 Wesley Marin, Jill Hollenbach, Paul Norman
#
# This file is part of PING.
#
# PING is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# PING is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with PING.  If not, see <http://www.gnu.org/licenses/>.


ping_extractor <- function(
  sample.location = "Sequences/",
  fastq.pattern.1 = "_1.fastq",
  fastq.pattern.2 = "_2.fastq",
  results.directory = "PING_sequences/",
  bowtie.threads = 4
  ) {
  
  library(data.table)
  
  ping.ready <- function() {
    cat("----- Getting PING_grabber ready -----\n\n")
    
    dir.create(results.directory, showWarnings = F)
    
    cat(paste(results.directory," directory created.\n\n"))
  }
  
  get_sequence_list <- function(folder.name = sample.location, file.pattern = fastq.pattern.1) {
    
    sequence_list = list.files(file.path(folder.name), pattern = file.pattern)
    
    if (is.na(sequence_list[1])) {
      string <- paste("No sequences found in", sample.location, "using fastq pattern", fastq.pattern.1)
      stop(string)
    } else {
      sequence_list <- gsub(file.pattern, "", sequence_list)
      cat(paste("Found sequences: ", paste(sequence_list, collapse = "\n"), sep = "\n"))
      cat("\n")
      return(sequence_list)
    }
  }
  
  ping.mrG <- function(sequence.list) {
    
    # Pull out reads that match any KIR ---------------------------------------
    
    grabber <- function(sequence) {
      
      bt2_p <- paste0("-p", bowtie.threads)
      bt2_5 <- "--trim5 3"
      bt2_3 <- "--trim3 7"
      bt2_L <- "-L 20"
      bt2_i <- "-i S,1,0.5"
      bt2_min_score <- "--score-min L,0,-0.187"
      bt2_I <- "-I 75"
      bt2_X <- "-X 1000"
      bt2_x <- "-x Resources/grabber_resources/Filters/mrG/output"
      
      bt2_1 <- paste0("-1 ", sample.location, sequence, fastq.pattern.1)
      bt2_2 <- paste0("-2 ", sample.location, sequence, fastq.pattern.2)
      
      sequence <- last(unlist(strsplit(sequence, "/")))
      bt2_stream <- paste0("-S ", results.directory ,sequence, ".temp")
       
      
      if(is_gz){
        bt2_al_conc <- paste0("--al-conc-gz ", results.directory, sequence, "_KIR_%.fastq.gz")
      }else{
        bt2_al_conc <- paste0("--al-conc ", results.directory, sequence, "_KIR_%.fastq")
      }
      
      bt2_un <- paste0("--un ",results.directory,sequence, ".dump.me")
      
      cat(sequence,"\n\n")
      cat("bowtie2", bt2_p, bt2_5, bt2_3, bt2_L, bt2_i, bt2_min_score, bt2_I, bt2_X, bt2_x, bt2_1, bt2_2, bt2_stream, bt2_al_conc, bt2_un,"\n\n")


      if(system("which bowtie2", intern=FALSE, ignore.stdout=TRUE, ignore.stderr=TRUE) == '0'){
        system2("bowtie2", c(bt2_p, bt2_5, bt2_3, bt2_L, bt2_i, bt2_min_score, bt2_I, bt2_X, bt2_x, bt2_1, bt2_2, bt2_stream, bt2_al_conc, bt2_un))
      }else{
        cat("\n\nbowtie2 not found in path\n\nExiting!!\n\n")
        q()
      }
      cat("\n\n")
      
      file.remove(bt2_stream)
      file.remove(bt2_un)
    }
      
    for(sample in sequence.list) {
      cat("\n\nRunning MrGrabWaller on: ")
      grabber(sample)
    }
    
    cat("MrGrabwaller is complete. Extracted reads are deposited in the PING_sequences folder.\n")
    cat("fastq.patterns have been adjusted to _KIR_1.fastq(.gz) and _KIR_2.fastq(.gz).\n")
  }
  
  ping.ready()
  
  sequence_list <- get_sequence_list()
  
  is_gz <- last(unlist(strsplit(fastq.pattern.1, ".", fixed = T))) == "gz"
  
  ping.mrG(sequence_list)
}
