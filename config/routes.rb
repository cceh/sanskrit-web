Sanskrit::Application.routes.draw do
	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	root :to => redirect('/dict')

	get '/dict', :to => 'dict#index'
	get '/dict/:lemma', :to => 'dict#show' # FIXME: choose a proper path
end
