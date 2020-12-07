project('bettercslice', 'd')

sources = files(
  'source/bettercslice.d',
)
incdir = include_directories('source')

bettercslice = library('bettercslice',
  sources,
  include_directories: incdir,
)

bettercslice_dep = declare_dependency(include_directories: incdir, link_with: bettercslice)
