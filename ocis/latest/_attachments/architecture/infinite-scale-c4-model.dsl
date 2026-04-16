/*
 * To be parsed via: https://structurizr.com/dsl
 * (Help available via selector on the left side below "Upload"
 * Then exported via button PlantUML
 * Then imported at http://www.plantuml.com/plantuml
 * Then exported as .svg image
*/

workspace "Infinite Scale" "The Infinite Scale C4 Model" {

    !impliedRelationships false

	model {
		guest = person "Guest" "A person outside the system"
		user = person "User" "A user known to the system"
		admin = person "Admin" "Manages the Infinite Scale platform"

		idm = softwareSystem "Identity Management" "Manages and authenticates users" "Existing System"
		storage = softwareSystem "Storage System" "POSIX, NFS, CephFS, EOS, Google, FTP, Cloud ..." "Existing System"
		ocis = softwareSystem "Infinite Scale" "Data Platform" {
		    ocdav = container "ocdav" "Infinite Scale flavoured WebDAV" "go, go-micro, reva"
		    users = container "user" "manages users" "go, reva" {
                -> idm "manages users with" "LDAP"
            }
		    ocs = container "ocs" "implements openCollaborationServices for sharing and user provisioning" "go, go-micro, reva" {
		        -> users "uses" "GRPC"
		    }
		    graph = container "graph" "libregraph for /me/drives and more" "go, go-micro" {
		        -> users "uses" "GRPC"
		    }
		    thumbnails = container "thumbnails" "generates and caches thumbnails" "go, go-micro"
            
            proxy = container "proxy" "routes requests based on the logged in user" "go, go-micro" {
                -> idm "Authenticates users with" "OpenId Connect"
                -> ocdav "forwards /(web)dav WebDAV API calls to" "HTTP"
                -> ocs "forwards /ocs API calls to" "HTTP"
                -> graph "forwards /graph API calls to" "HTTP"
                -> thumbnails "forwards thumbnail preview requests to" "HTTP"
            }
            webui = container "oCIS web" "File management Web UI" "vue.js" "Web Browser" {
        		-> idm "Makes API calls to" "OpenId Connect"
            }
            web = container "web" "Delivers the static content and the ocis web single page application" "golang"  { 
                -> webui "Delivers to the users web browser"
            }
            desktopclient = container "Desktop client" "Sync spaces with a computer (win, mac, linux)" "C++, QT" {
        		-> idm "Makes API calls to" "OpenId Connect"
        		-> proxy "syncs with" "WebDAV, OCS, LibreGraph"
        	}
            androidapp = container "Android App" "cloud storage for android devices" "kotlin, JAVA" "Mobile App" {
        		-> idm "Makes API calls to" "OpenId Connect"
            }
            iosapp = container "iOS App" "cloud storage for iOS devices" "Swift, Objective-C" "Mobile App" {
        		-> idm "Makes API calls to" "OpenId Connect"
            }
            
         }
		user -> ocis "Syncs and shares spaces with"
		guest -> ocis "Syncs and shares shared resources with"
		admin -> ocis "manages"
		ocis -> idm "Authenticates and manages users with" "OpenId Connect, LDAP"
		ocis -> storage "Manages access to" "POSIX, SMB, S3, ..."
	}

	views {
		systemlandscape "SystemLandscape" {
		    include ocis idm storage guest user admin
			autoLayout
		}

		systemContext ocis "SystemContext" "System context of an oCIS instance" {
			include ocis idm storage guest user admin
			autoLayout
		}
		
        container ocis {
            include *
            autoLayout
        }

		styles {
			element "Software System" {
				background #1168bd
				color #ffffff
			}
			element "Existing System" {
				background #999999
				color #ffffff
			}
			element "Person" {
				shape person
				background #08427b
				color #ffffff
			}
		}
	}
}
