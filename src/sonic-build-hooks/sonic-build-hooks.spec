Name:           sonic-build-hooks
Version:        1.0
Release:        1%{?dist}
Summary:        SONiC build hooks for RPM-based systems
License:        Apache-2.0
BuildArch:      noarch
Requires:       bash
Requires:       dnf
Requires:       rpm
Requires:       coreutils
Requires:       curl
Requires:       wget

Source0:        scripts
Source1:        hooks

%description
Hooks the build tools such as dnf, rpm, wget, pip, etc.
It is used to monitor and control the packages installed during the build.

%install
mkdir -p %{buildroot}/usr/local/share/buildinfo/scripts
mkdir -p %{buildroot}/usr/local/share/buildinfo/hooks
mkdir -p %{buildroot}/usr/local/share/buildinfo/config
mkdir -p %{buildroot}/usr/sbin

# Copy scripts and hooks from SOURCES
cp -r %{_sourcedir}/scripts/* %{buildroot}/usr/local/share/buildinfo/scripts/
cp -r %{_sourcedir}/hooks/* %{buildroot}/usr/local/share/buildinfo/hooks/
chmod +x %{buildroot}/usr/local/share/buildinfo/scripts/*
chmod +x %{buildroot}/usr/local/share/buildinfo/hooks/*

# Create convenience symlinks in /usr/sbin
cd %{buildroot}/usr/sbin
for f in symlink_build_hooks post_run_buildinfo pre_run_buildinfo collect_version_files post_run_cleanup; do
    ln -sf ../local/share/buildinfo/scripts/$f $f
done

%files
/usr/local/share/buildinfo
/usr/sbin/symlink_build_hooks
/usr/sbin/post_run_buildinfo
/usr/sbin/pre_run_buildinfo
/usr/sbin/collect_version_files
/usr/sbin/post_run_cleanup
