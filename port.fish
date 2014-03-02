# Fish shell completions for the MacPorts package manager, port.

complete -c port -s v --description 'generate verbose messages'
complete -c port -s d --description 'generate debugging messages, implies -v'
complete -c port -s q --description 'quiet mode, suppress messages'
complete -c port -s n --description 'don\'t upgrade dependencies'
complete -c port -s R --description 'also upgrade dependents'
complete -c port -s u --description 'uninstall non-active ports when upgrading and uninstalling'
complete -c port -s f --description 'force mode (ignore state file)'
complete -c port -s o --description 'honor state files even if Portfile has been modified since'
complete -c port -s s --description 'source-only mode'
complete -c port -s b --description 'binary-only mode'
complete -c port -s c --description 'execute clean after install'
complete -c port -s k --description 'don\'t autoclean after install'
complete -c port -s D --description 'specify portdir'
complete -c port -s F --description 'read and process the file of commands specified by the argument'
complete -c port -s p --description 'proceed to process multiple ports after errors occured'
complete -c port -s y --description 'perform a dry run'
complete -c port -s t --description 'enable trace mode debug facilities'

function __fish_complete_port_search
  # - search ports with last user entry + '*'
  # - or just a list of pseudo-ports, given as argv[1], e.g. installed
  #   in that case argv[2] can be "nameonly", which will not print version and +variant info

    set -l query $argv[1]
    set -l lastentry (commandline -ct | tr -d ' ')
    set -l searchflag
    if [ (count $argv) = 2 ]
      set searchflag $argv[2]
    end

    # suggest variants instead of portnames
    if [ (echo "$lastentry" | cut -c 1) = "+" ]
      set -l cmd (commandline -top)
      # find the portname by going backwards in the commandline
      for subcmd in $cmd[-1..1]
        switch $subcmd
          case "-*"
            continue
          case "+*"
            continue
          case '*'
            if contains -- $subcmd all current active inactive actinact installed uninstalled outdated obsolete requested unrequested leaves
              # don't lookup pseudo-portnames
              return
            else
              port info --variants --line $subcmd ^ /dev/null | tr "," "\n" | awk '{print "+" $0}'
              return
            end
        end
      end
    end

    if [ -z "$query" ]
      if [ -z "$lastentry" ]
        # don't give a list of 18000+ suggestions, expect at least one character
        return
      else
        set query {$lastentry}'*'
      end
    end

    if [ "$searchflag" = "nameonly" ]
      # only name, no version +variant
      port echo "$query" ^ /dev/null | cut -d " " -f1
    else
      port echo "$query" ^ /dev/null | tr -d ' '
    end
end

function __fish_complete_port --description 'Complete port (MacPorts) operands'
    # every completion passes through here to check whether it's supposed to be used
    
    # args to this function say what target the suggestion is for
    set -l sugg_length (count $argv)
    set -l suggestion $argv[1]
    set -l sugg_flag
    if [ $sugg_length = 2 ]
      set sugg_flag $argv[2]
    end

    # set operand_string as a local variable containing the current command-line token.
    set -l cmd (commandline -top)
    set -l lastcmd (commandline -topc)[-1]

    # "sudo port info --<tab>"
    # --> cmd: "port info --"
    # --> lastcmd: "info"

    # authorative flags, allowing nothing else:
    switch $lastcmd
      case "--phase"
          if [ "$sugg_flag" != "--phase" ]
            return 1
          end
      case "--level"
          if [ "$sugg_flag" != "--level" ]
            return 1
          end
    end

    set -l port_targets search info notes variants deps rdeps dependents rdependents install uninstall select activate deactivate setrequested unsetrequested installed location contents provides sync outdated upgrade rev clean log logfile echo list mirror version platform selfupdate load unload gohome usage help

    set -l target
    for port_target in $port_targets
      if contains -- $port_target $cmd
        set target $port_target
        break
      end
    end

    if [ -z "$target" ]
      if [ "$suggestion" = "target" ]
        return 0
      end

    else # -n "$target"

      # we have a target but you want to suggest another? NO
      if [ "$lastcmd" = "help" -a "$suggestion" = "target" ]
        return 0
      end

#      if [ "$suggestion" = "pseudo" -a not "$target" != "select" -a "$target" != "help" ]
      if [ "$suggestion" = "pseudo" ]
        if not contains -- $target select help search
          return 0
        end
      end

      if [ "$suggestion" = "search/info" ]
        if [ "$target" = "search" -o "$target" =  "info" ]
          return 0
        end
      end

      # you want to suggest something for the current target?
      if [ "$target" = "$suggestion" ]
        return 0
      end

    end

    # default: NO
    return 1
end


### Targets ###
complete -f -c port -n '__fish_complete_port target' -r -a "search info notes variants deps rdeps dependents rdependents install uninstall select activate deactivate setrequested unsetrequested installed location contents provides sync outdated upgrade rev-upgrade clean log logfile echo list mirror version platform selfupdate load unload gohome usage help"

### Suggestions by target ###
complete -f -c port -n '__fish_complete_port info'           -a '(__fish_complete_port_search)'
complete -f -c port -n '__fish_complete_port notes'          -a '(__fish_complete_port_search)'
complete -f -c port -n '__fish_complete_port variants'       -a '(__fish_complete_port_search)'
complete -f -c port -n '__fish_complete_port deps'           -a '(__fish_complete_port_search)'
complete -f -c port -n '__fish_complete_port rdeps'          -a '(__fish_complete_port_search)'
complete -f -c port -n '__fish_complete_port dependents'     -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port rdependents'    -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port install'        -a '(__fish_complete_port_search)'
complete -f -c port -n '__fish_complete_port uninstall'      -a '(__fish_complete_port_search installed)'
complete -f -c port -n '__fish_complete_port select'         -a "(port echo '*_select' | cut -d_ -f1)"
complete -f -c port -n '__fish_complete_port activate'       -a '(__fish_complete_port_search inactive)'
complete -f -c port -n '__fish_complete_port deactivate'     -a '(__fish_complete_port_search active)'
complete -f -c port -n '__fish_complete_port setrequested'   -a '(__fish_complete_port_search unrequested nameonly)'
complete -f -c port -n '__fish_complete_port unsetrequested' -a '(__fish_complete_port_search requested nameonly)'
complete -f -c port -n '__fish_complete_port installed'      -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port location'       -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port contents'       -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port upgrade'        -a "(__fish_complete_port_search outdated nameonly)"
complete -f -c port -n '__fish_complete_port clean'          -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port log'            -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port logfile'        -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port list'           -a '(__fish_complete_port_search)'
complete -f -c port -n '__fish_complete_port mirror'         -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port load'           -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port unload'         -a '(__fish_complete_port_search installed nameonly)'
complete -f -c port -n '__fish_complete_port gohome'         -a '(__fish_complete_port_search)'

### Pseudo port names ###
complete -f -c port -n '__fish_complete_port pseudo'         -a "all current active inactive actinact installed uninstalled outdated obsolete requested unrequested leaves"

### Flags ###
complete -f -c port -n '__fish_complete_port search/info' -l category
complete -f -c port -n '__fish_complete_port search/info' -l depends_fetch
complete -f -c port -n '__fish_complete_port search/info' -l depends_extract
complete -f -c port -n '__fish_complete_port search/info' -l depends_build
complete -f -c port -n '__fish_complete_port search/info' -l depends_lib
complete -f -c port -n '__fish_complete_port search/info' -l depends_run
complete -f -c port -n '__fish_complete_port search/info' -l description
complete -f -c port -n '__fish_complete_port search/info' -l epoch
complete -f -c port -n '__fish_complete_port search/info' -l fullname
complete -f -c port -n '__fish_complete_port search/info' -l heading
complete -f -c port -n '__fish_complete_port search/info' -l homepage
complete -f -c port -n '__fish_complete_port search/info' -l license
complete -f -c port -n '__fish_complete_port search/info' -l long_description
complete -f -c port -n '__fish_complete_port search/info' -l maintainer
complete -f -c port -n '__fish_complete_port search/info' -l maintainers
complete -f -c port -n '__fish_complete_port search/info' -l name
complete -f -c port -n '__fish_complete_port search/info' -l platform
complete -f -c port -n '__fish_complete_port search/info' -l platforms
complete -f -c port -n '__fish_complete_port search/info' -l portdir
complete -f -c port -n '__fish_complete_port search/info' -l replaced_by
complete -f -c port -n '__fish_complete_port search/info' -l revision
complete -f -c port -n '__fish_complete_port search/info' -l subports
complete -f -c port -n '__fish_complete_port search/info' -l variant
complete -f -c port -n '__fish_complete_port search/info' -l variants
complete -f -c port -n '__fish_complete_port search/info' -l version

complete -f -c port -n '__fish_complete_port search' -l line            -d "display each result on a single line"
complete -f -c port -n '__fish_complete_port search' -l regex           -d "treat search string as regular expression"
complete -f -c port -n '__fish_complete_port search' -l exact           -d "treat search string as a literal"
complete -f -c port -n '__fish_complete_port search' -l case-sensitive  -d "treat search string case sensitive"

complete -f -c port -n '__fish_complete_port info' -l depends           -d "An abbreviation for all depends_* fields"
complete -f -c port -n '__fish_complete_port info' -l line              -d "output single line per port for further processing"
complete -f -c port -n '__fish_complete_port info' -l pretty            -d "nicer formatting, default when no options specified"
complete -f -c port -n '__fish_complete_port info' -l index             -d "pull info from PortIndex instead of Portfile"

complete -f -c port -n '__fish_complete_port rdeps' -l full      -d "display full dependecy tree instead of only showing each port once"
complete -f -c port -n '__fish_complete_port rdeps' -l index     -d "take dependency information from the PortIndex instead of the Portfile"
complete -f -c port -n '__fish_complete_port rdeps' -l no-build  -d "exclude dependencies that are only needed at build time"

complete -f -c port -n '__fish_complete_port rdependents' -l full -d "display the full tree of dependents instead of only showing each port once"

complete -f -c port -n '__fish_complete_port uninstall' -o u -d "uninstall all installed but inactive ports"
complete -f -c port -n '__fish_complete_port uninstall' -l follow-dependents -d "recursively uninstall all ports that depend on the port before uninstalling the port itself"
complete -f -c port -n '__fish_complete_port uninstall' -l follow-dependencies -d "uninstall a port and then recursively uninstall all ports it depended on"

complete -f -c port -n '__fish_complete_port select' -l list   -d "list the available versions in a group"
complete -f -c port -n '__fish_complete_port select' -l show   -d "show currently selected version for a group"
complete -f -c port -n '__fish_complete_port select' -l set    -d "change currently selected version for a group"

complete -f -c port -n '__fish_complete_port upgrade' -o n                   -d "upgrade port without following its dependencies"
complete -f -c port -n '__fish_complete_port upgrade' -l force               -d "force an upgrade (rebuild)"
complete -f -c port -n '__fish_complete_port upgrade' -l enforce-variants    -d "rebuild the port to change the selected variants"
complete -f -c port -n '__fish_complete_port upgrade' -l no-rev-upgrade      -d "disable check for broken ports after upgrade"

complete -f -c port -n '__fish_complete_port rev-upgrade' -l id-loadcmd-check -d "run more checks against a special loadcommand in Mach-O binaries"

complete -f -c port -n '__fish_complete_port clean' -l work      -d "just remove the work files (default)"
complete -f -c port -n '__fish_complete_port clean' -l dist      -d "remove the distribution files (tarballs, etc)"
complete -f -c port -n '__fish_complete_port clean' -l archive   -d "remove any archives of a port that remain in the temporary download directory"
complete -f -c port -n '__fish_complete_port clean' -l logs      -d "remove the log files for a port"
complete -f -c port -n '__fish_complete_port clean' -l all       -d "remove the work files, distribution files, temporary archives and logs"
complete -f -c port -n '__fish_complete_port clean' -l archive   -d "remove only certain version(s) of a port’s temporary archives"

complete -f -r -c port -n '__fish_complete_port log' -l phase       -d "filter log files by some criterions"
complete -f -r -c port -n '__fish_complete_port log' -l level       -d "specify message category"

complete -A -f -c port -n "__fish_complete_port log --phase"        -a "fetch checksum extract patch configure build test destroot install activate"
complete -A -f -c port -n "__fish_complete_port log --level"        -a "error warn msg info debug"

complete -A -f -c port -n "__fish_complete_port mirror" -l new      -d "reset the filemap database"
