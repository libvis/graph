modname = graph
get_path = libvis-mods where
front_src = $(shell $(get_path) --front)
back_src = $(shell $(get_path) --back)

install:
	webvis_mods install

requirements: req_py req_js
	@echo "Installed requirements"

req_py:
	pip3 install -r py_requirements.txt --user

req_js:
	if [ ! -z "$(shell yarn --version)" ]; then \
		cd $(front_src)/$(modname) &&\
			cat js_requirements.txt | xargs yarn add ;\
	else\
		cd $(front_src)/$(modname) &&\
			cat js_requirements.txt | xargs npm i ;\
	fi
