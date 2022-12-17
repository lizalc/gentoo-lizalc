# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop pax-utils xdg optfeature

MY_URL_ID="edc432e920c3ec2c2af5e8a99b8e4b782633d298"
MY_PV="${PV##*.*.*.}"

DESCRIPTION="Multiplatform Visual Studio Code from Microsoft - Insiders Edition"
HOMEPAGE="https://code.visualstudio.com"
SRC_URI="
	amd64? ( https://az764295.vo.msecnd.net/insider/${MY_URL_ID}/code-insider-x64-${MY_PV}.tar.gz -> ${P}-amd64.tar.gz )
"
S="${WORKDIR}"

RESTRICT="mirror strip bindist"

LICENSE="
	Apache-2.0
	BSD
	BSD-1
	BSD-2
	BSD-4
	CC-BY-4.0
	ISC
	LGPL-2.1+
	Microsoft-vscode
	MIT
	MPL-2.0
	openssl
	PYTHON
	TextMate-bundle
	Unlicense
	UoI-NCSA
	W3C
"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	|| (
		>=app-accessibility/at-spi2-core-2.46.0:2
		( app-accessibility/at-spi2-atk dev-libs/atk )
	)
	app-crypt/libsecret[crypt]
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/util-linux
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/libxshmfence
	x11-libs/pango
"

QA_PREBUILT="
	/opt/${PN}/bin/code-tunnel
	/opt/${PN}/chrome_crashpad_handler
	/opt/${PN}/chrome-sandbox
	/opt/${PN}/code-insiders
	/opt/${PN}/libEGL.so
	/opt/${PN}/libffmpeg.so
	/opt/${PN}/libGLESv2.so
	/opt/${PN}/libvk_swiftshader.so
	/opt/${PN}/libvulkan.so*
	/opt/${PN}/resources/app/extensions/*
	/opt/${PN}/resources/app/node_modules.asar.unpacked/*
	/opt/${PN}/swiftshader/libEGL.so
	/opt/${PN}/swiftshader/libGLESv2.so
"

src_install() {
	if use amd64; then
		cd "${WORKDIR}/VSCode-linux-x64" || die
	else
		die "Visual Studio Code only supports amd64, arm and arm64"
	fi

	# Cleanup
	rm -r ./resources/app/LICENSES.chromium.html ./resources/app/LICENSE.rtf || die

	# Disable update server
	sed -e "/updateUrl/d" -i ./resources/app/product.json || die

	# Install
	pax-mark m ${PN}
	insinto "/opt/${PN}"
	doins -r *
	fperms +x /opt/${PN}/{,bin/}${PN}
	fperms +x /opt/${PN}/chrome_crashpad_handler
	fperms 4711 /opt/${PN}/chrome-sandbox
	fperms 755 /opt/${PN}/resources/app/extensions/git/dist/{askpass,git-editor}{,-empty}.sh
	fperms -R +x /opt/${PN}/resources/app/out/vs/base/node
	fperms +x /opt/${PN}/resources/app/node_modules.asar.unpacked/@vscode/ripgrep/bin/rg
	dosym "../../opt/${PN}/bin/${PN}" "usr/bin/vs${PN}"
	dosym "../../opt/${PN}/bin/${PN}" "usr/bin/${PN}"
	domenu "${FILESDIR}/${PN}.desktop"
	domenu "${FILESDIR}/${PN}-url-handler.desktop"
	newicon "resources/app/resources/linux/code.png" "${PN}.png"
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "You may want to install some additional utils, check in:"
	elog "https://code.visualstudio.com/Docs/setup#_additional-tools"
	optfeature "keyring support inside vscode" "gnome-base/gnome-keyring"
}