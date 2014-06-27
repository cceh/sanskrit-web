Sanskrit::Application.routes.draw do
	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	root :to => redirect('/dict')

	get '/dict', :to => 'dict#index'
	get '/dict/:lemma', :to => 'dict#show' # FIXME: choose a proper path

	get '/dictionary', :to => redirect('/dictionaries')
	get '/dictionaries', :to => 'dictionaries#index'
	resources :dictionary, :controller => 'dictionaries', :only => [:index, :show] do
		# FIXME: /dictionary/X/scans
		resources :scan, :controller => 'scans', :only => [:index, :show]
	end
end
