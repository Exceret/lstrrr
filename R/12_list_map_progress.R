.list_progress_enabled <- function(.progress) {
  isTRUE(.progress) || is.character(.progress)
}

.list_progress_name <- function(.progress, default = NULL) {
  if (is.character(.progress) && length(.progress) == 1L && nzchar(.progress)) {
    .progress
  } else {
    default
  }
}

.list_progress_start <- function(.progress, total, default = NULL) {
  if (!.list_progress_enabled(.progress)) {
    return(NULL)
  }

  if (is.na(total) || total <= 0L) {
    return(NULL)
  }

  # create the progress bar in the caller's environment
  id <- cli::cli_progress_bar(
    name = .list_progress_name(.progress = .progress, default = default),
    total = total
  )

  id
}

.list_progress_tick <- function(id) {
  if (!is.null(id)) {
    cli::cli_progress_update(id = id)
  }

  invisible(NULL)
}

.list_progress_done <- function(id) {
  if (!is.null(id)) {
    cli::cli_progress_done(id = id)
  }

  invisible(NULL)
}
