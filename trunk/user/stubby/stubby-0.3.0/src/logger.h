#ifndef STUBY_LOGGER_H
#define STUBY_LOGGER_H

#if !defined(STUBBY_ON_WINDOWS) && !defined(GETDNS_ON_WINDOWS)
  extern void fprint_log(FILE *stream, const char *fmt, ...);
#else
  #define fprint_log(FILE, fmt, args...) fprintf(FILE, fmt, ## args)
#endif

#endif
