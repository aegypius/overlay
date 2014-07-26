FROM aegypius/overlay-env

# Install a proper editor
RUN emerge app-editors/vim

# Portage development utils
RUN emerge app-portage/eix
RUN emerge app-portage/gentoolkit
