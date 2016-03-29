PLUGIN = pwd

SOURCE = doc/pwd.txt
SOURCE += syntax/pwd.vim
SOURCE += plugin/pwd.vim
SOURCE += ftdetect/pwd.vim

all: ${PLUGIN}.vmb ${PLUGIN}.tgz

${PLUGIN}.vmb: ${SOURCE}
	vim --cmd 'let g:plugin_name="${PLUGIN}"' -s build.vim

${PLUGIN}.tgz: ${SOURCE}
	tar czvf $@ $^

install: all
	rsync -Rv ${SOURCE} ${HOME}/.vim/

clean:
	rm ${PLUGIN}.vmb
