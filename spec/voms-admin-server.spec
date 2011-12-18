Name: voms-admin-server
Version: 2.7.0
Release: 1%{?dist}
Summary: The VOMS Administration service

Group:		Applications/Internet
License: ASL 2.0
URL: https://twiki.cnaf.infn.it/twiki/bin/view/VOMS
Source:  %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch

BuildRequires:  maven
BuildRequires:  jpackage-utils
BuildRequires:  java-devel
BuildRequires:  oracle-instantclient-basic

Requires: emi-trustmanager
Requires: bouncycastle >= 1.39
Requires: tomcat
Requires: java

%description
The Virtual Organization Membership Service (VOMS) is an attribute authority
which serves as central repository for VO user authorization information,
providing support for sorting users into group hierarchies, keeping track of
their roles and other attributes in order to issue trusted attribute
certificates and SAML assertions used in the Grid environment for
authorization purposes.


The VOMS Admin service is a web application providing tools for administering
the VOMS VO structure. It provides an intuitive web user interface for daily
administration tasks.

%prep
%setup -q

%build
mvn -B package

%install
mkdir -p $RPM_BUILD_ROOT
tar -C $RPM_BUILD_ROOT -xvzf target/%{name}-%{version}.tar.gz

%clean
rm -rf $RPM_BUILD_ROOT

%files

defattr(-,root,root,-)

%{_initrddir}/voms-admin

%dir %{_sysconfdir}/voms-admin
%config(noreplace) %{_sysconfdir}/sysconfig/voms-admin

%{_sbindir}/init-voms-admin.py
%{_sbindir}/voms-db-deploy.py
%{_sbindir}/voms-admin-configure
%{_sbindir}/voms-admin-configure.py
%{_sbindir}/voms.py
%{_sbindir}/voms-admin-ping

%{_javadir}/glite-security-voms-admin.jar
%{_datadir}/webapps/glite-security-voms-admin.war
%{_datadir}/webapps/glite-security-voms-siblings.war

%doc AUTHORS NEWS README license.txt

%{_datadir}/voms-admin/*

%changelog

* Fri Dec 16 2011 Andrea Ceccanti <andrea.ceccanti at cnaf.infn.it> - 2.0.7-1
- Self-managed packaging
