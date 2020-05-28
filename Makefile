modname = graph
get_path = webvis-mods where
front_src = $(shell $(get_path) --front)
back_src = $(shell $(get_path) --back)

install:
	webvis_mods install

requirements: req_py req_js
	@echo "Installed requirements"

req_py:
	pip3 install -r py_requirements.txt --user

req_js:
	cd $(front_src)/$(modname) &&\
		cat js_requirements.txt | xargs yarn add


