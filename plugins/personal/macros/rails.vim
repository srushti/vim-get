silent! let &l:grepprg=substitute(&grepprg, '\$\*', '--exclude-dir=log --exclude-dir=tmp --exclude-dir=doc --exclude-dir=coverage \0', '')
silent! let &l:path .= ',' . rails#app().path('app/workers')
silent! let &l:path .= ',' . rails#app().path('app/coffescripts')
silent! let &l:path .= ',' . rails#app().path('config')

Rnavcommand factory spec/factories -glob=* -suffix=_factory.rb -default=model()
Rnavcommand worker app/workers -glob=*
Rnavcommand coffescript app/coffescripts -glob=*
Rnavcommand config config -glob=* -suffix=.yml

