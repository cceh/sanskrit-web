Sanskrit::Application.routes.draw do
	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	root :to => 'high_voltage/pages#show', id: 'home'

	get '/search', :to => 'search#index'

	get '/dictionary', :to => redirect('/dictionaries')
	get '/dictionaries', :to => 'dictionaries#index'
	resources :dictionary, :controller => 'dictionaries', :only => [:index, :show] do
		get '/lemmas', :to => 'lemmas#index'
		resources :lemma, :controller => 'lemmas', :only => [:index, :show]

		get '/scans', :to => 'scans#index'
		resources :scan, :controller => 'scans', :only => [:index, :show]
	end
end
