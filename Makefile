# You should configure etckeeper.conf for your distribution before
# installing etckeeper.
CONFFILE=etckeeper.conf
include $(CONFFILE)

DESTDIR?=
prefix=/usr
bindir=${prefix}/bin
etcdir=/etc
mandir=${prefix}/share/man
vardir=/var
CP=cp -R
INSTALL=install 
INSTALL_EXE=${INSTALL}
INSTALL_DATA=${INSTALL} -m 0644
PYTHON=python

build: etckeeper.spec etckeeper.version
	-$(PYTHON) ./etckeeper-bzr/__init__.py build || echo "** bzr support not built"
	-$(PYTHON) ./etckeeper-dnf/etckeeper.py build || echo "** DNF support not built"

install: etckeeper.version
	mkdir -p $(DESTDIR)$(etcdir)/etckeeper/ $(DESTDIR)$(vardir)/cache/etckeeper/
	$(CP) *.d $(DESTDIR)$(etcdir)/etckeeper/
	$(INSTALL_DATA) $(CONFFILE) $(DESTDIR)$(etcdir)/etckeeper/etckeeper.conf
	mkdir -p $(DESTDIR)$(bindir)
	$(INSTALL_EXE) etckeeper $(DESTDIR)$(bindir)/etckeeper
	mkdir -p $(DESTDIR)$(mandir)/man8
	$(INSTALL_DATA) etckeeper.8 $(DESTDIR)$(mandir)/man8/etckeeper.8
	mkdir -p $(DESTDIR)$(etcdir)/bash_completion.d
	$(INSTALL_DATA) bash_completion $(DESTDIR)$(etcdir)/bash_completion.d/etckeeper
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),apt)
	mkdir -p $(DESTDIR)$(etcdir)/apt/apt.conf.d
	$(INSTALL_DATA) apt.conf $(DESTDIR)$(etcdir)/apt/apt.conf.d/05etckeeper
	mkdir -p $(DESTDIR)$(etcdir)/cruft/filters-unex
	$(INSTALL_DATA) cruft_filter $(DESTDIR)$(etcdir)/cruft/filters-unex/etckeeper
endif
ifeq ($(LOWLEVEL_PACKAGE_MANAGER),pacman-g2)
	mkdir -p $(DESTDIR)$(etcdir)/pacman-g2/hooks
	$(INSTALL_DATA) pacman-g2.hook $(DESTDIR)$(etcdir)/pacman-g2/hooks/etckeeper
endif
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),yum)
	mkdir -p $(DESTDIR)$(prefix)/lib/yum-plugins
	$(INSTALL_DATA) yum-etckeeper.py $(DESTDIR)$(prefix)/lib/yum-plugins/etckeeper.py
	mkdir -p $(DESTDIR)$(etcdir)/yum/pluginconf.d
	$(INSTALL_DATA) yum-etckeeper.conf $(DESTDIR)$(etcdir)/yum/pluginconf.d/etckeeper.conf
endif
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),dnf)
	-$(PYTHON) ./etckeeper-dnf/etckeeper.py install --root=$(DESTDIR) ${PYTHON_INSTALL_OPTS} || echo "** DNF support not installed"
endif
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),zypper)
	mkdir -p $(DESTDIR)$(prefix)/lib/zypp/plugins/commit
	$(INSTALL) zypper-etckeeper.py $(DESTDIR)$(prefix)/lib/zypp/plugins/commit/zypper-etckeeper.py
endif
	-$(PYTHON) ./etckeeper-bzr/__init__.py install --root=$(DESTDIR) ${PYTHON_INSTALL_OPTS} || echo "** bzr support not installed"
	echo "** installation successful"

clean: etckeeper.spec etckeeper.version
	rm -rf build

uninstall:
	rm -rf $(DESTDIR)$(etcdir)/etckeeper/
	rm -rf $(DESTDIR)$(vardir)/cache/etckeeper/
	rm -f $(DESTDIR)$(bindir)/etckeeper
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(bindir)
	rm -f $(DESTDIR)$(mandir)/man8/etckeeper.8
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(mandir)/man8
	rm -f $(DESTDIR)$(etcdir)/bash_completion.d/etckeeper
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(etcdir)/bash_completion.d
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),apt)
	rm -f $(DESTDIR)$(etcdir)/apt/apt.conf.d/05etckeeper
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(etcdir)/apt/apt.conf.d
	rm -f $(DESTDIR)$(etcdir)/cruft/filters-unex/etckeeper
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(etcdir)/cruft/filters-unex
endif
ifeq ($(LOWLEVEL_PACKAGE_MANAGER),pacman-g2)
	rm -f $(DESTDIR)$(etcdir)/pacman-g2/hooks/etckeeper
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(etcdir)/pacman-g2/hooks
endif
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),yum)
	rm -f $(DESTDIR)$(prefix)/lib/yum-plugins/etckeeper.py
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(prefix)/lib/yum-plugins
	rm -f $(DESTDIR)$(etcdir)/yum/pluginconf.d/etckeeper.conf
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(etcdir)/yum/pluginconf.d
endif
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),dnf)
	echo "** DNF support must be manually uninstalled"
endif
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),zypper)
	rm -f $(DESTDIR)$(prefix)/lib/zypp/plugins/commit/zypper-etckeeper.py
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(prefix)/lib/zypp/plugins/commit
	rmdir --ignore-fail-on-non-empty $(DESTDIR)$(prefix)/lib/zypp/plugins
endif
	echo "** bzr support must be manually uninstalled"
	echo "** partial uninstallation successful"

etckeeper.spec:
	sed -i~ "s/Version:.*/Version: $$(perl -e '$$_=<>;print m/\((.*?)\)/'<debian/changelog)/" etckeeper.spec
	rm -f etckeeper.spec~

etckeeper.version:
	sed -i~ "s/Version:.*/Version: $$(perl -e '$$_=<>;print m/\((.*?)\)/'<debian/changelog)\"/" etckeeper
	rm -f etckeeper~

.PHONY: etckeeper.spec etckeeper.version
