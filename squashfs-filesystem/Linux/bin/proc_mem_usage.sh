#!/etc/bash

lib_hdr=0
VERBOSE=0
LIST_SHARED=0

dll_code=0
dll_wdata=0
dll_rdata=0

dll_tot_code=0
dll_tot_wdata=0
dll_tot_rdata=0

print_lib ()
{
  if [ ${lib_hdr} -eq 0 ] ; then
    lib_hdr=1
    printf "%-40.40s  %7.7s     %7.7s     %7.7s\n" "Name" "Code" "rwData" "roData"
  fi
  printf "%-40.40s  %7d Kb  %7d Kb  %7d Kb\n" ${1} $(expr ${dll_code} / 1024) $(expr ${dll_wdata} / 1024) $(expr ${dll_rdata} / 1024)
}

tot_lib ()
{
  let "dll_tot_code = ${dll_tot_code} + ${dll_code}"
  let "dll_tot_wdata = ${dll_tot_wdata} + ${dll_wdata}"
  let "dll_tot_rdata = ${dll_tot_rdata} + ${dll_rdata}"

  dll_code=0
  dll_wdata=0
  dll_rdata=0
}

mem_usage_id()
{
  pgm_inode=0
  pgm_name=":"
  pgm_code=0
  pgm_ro_an=0
  pgm_rw_an=0
  pgm_wdata=0
  pgm_rdata=0
  pgm_heap=0
  pgm_stack=0
  pgm_shm=0


  lib_hdr=0
  curr_inode=0
  curr_lib_name=":"

  dll_code=0
  dll_wdata=0
  dll_rdata=0

  dll_tot_code=0
  dll_tot_wdata=0
  dll_tot_rdata=0
  empty=1

  while read address perm offset device inode filename ; do

    empty=0

    start=$((16#${address%-[0-9a-fA-F]*}))
    end=$((16#${address#[0-9a-fA-F]*-}))
    let "seg_size= (${end} - ${start})"

    if [ "${perm:3:1}" = "s" ] ; then
      # shared memory
      let "pgm_shm = ${pgm_shm} + ${seg_size}"
      continue
    fi

    if [ ${inode} -eq 0 ] ; then
      # heap segment
      if [ "x${filename}" = "x[heap]" ] ; then
        let "pgm_heap = ${pgm_heap} + ${seg_size}"
        continue
      fi

      # stack segment
      if [ "x${filename}" = "x[stack]" ] ; then
        let "pgm_stack = ${pgm_stack} + ${seg_size}"
        continue
      fi

      # otherwise anonymous segment
      if [ "${perm:1:1}" = "w" ] ; then
        let "pgm_rw_an = ${pgm_rw_an} + ${seg_size}"
      else
        let "pgm_ro_an = ${pgm_ro_an} + ${seg_size}"
      fi
      continue
    fi

    if [ ${inode} -ne ${curr_inode} -a ${inode} -ne ${pgm_inode} ] ; then
      if [ "${pgm_name}" = ":" -o "${curr_lib_name}" = ":" ] ; then
        dir=$(dirname ${filename})

        while true ; do

          cdir=$(basename ${dir})
          dir=$(dirname ${dir})

          if [ "${cdir}" = "lib" ] ; then
            if [ "${curr_lib_name}" = ":" ] ; then
              curr_inode=${inode}
              curr_lib_name=${filename}
            fi
            break
          fi

          if [ "$cdir" = "bin" -o "${cdir}" = "sbin" ] ; then
            # should always be true
            if [ "${pgm_name}" = ":" ] ; then
              pgm_name=${filename}
              pgm_inode=${inode}
            fi
            break
          fi

          if [ "${dir}" = "/" ] ; then
            if [ "${pgm_name}" = ":" ] ; then
              echo "===> Assumming $filename as (or part of) main program/module"
              pgm_name=${filename}
              pgm_inode=${inode}
              break
            fi
            echo "===> Assumming $filename as shared library"
            curr_inode=${inode}
            curr_lib_name=${filename}
            break
          fi

        done
      fi
    fi

    # main program/module
    if [ ${inode} -eq ${pgm_inode} ] ; then
      # code
      if [ "${perm}" = "r-xp" ] ; then
        let "pgm_code = ${pgm_code} + ${seg_size}"
        continue
      fi

      # bss and static data
      if [ "${perm}" = "rw-p" ] ; then
        let "pgm_wdata = ${pgm_wdata} + ${seg_size}"
        continue
      fi

      # otherwise internal(---p)/RO(r--p) data
      let "pgm_rdata = ${pgm_rdata} + ${seg_size}"
      continue
    fi

    # shared library

    if [ ! "${curr_inode}" = "${inode}" ] ; then

      if [ ${LIST_SHARED} -eq 1 ] ; then
        print_lib ${curr_lib_name}
      fi

      tot_lib

      curr_inode=${inode}
      curr_lib_name=${filename}
    fi

    # code
    if [ "${perm}" = "r-xp" ] ; then
      let "dll_code = ${dll_code} + ${seg_size}"
      continue
    fi

    # bss and static data
    if [ "${perm}" = "rw-p" ] ; then
      let "dll_wdata = ${dll_wdata} + ${seg_size}"
      continue
    fi

    # otherwise internal(---p)/RO(r--p) data
    let "dll_rdata = ${dll_rdata} + ${seg_size}"

  done </proc/${1}/maps

  if [ ${empty} -eq 1 ] ; then
    return
  fi

  if [ ! "${curr_inode}" = ":" ] ; then
    if [ ${LIST_SHARED} -eq 1 ] ; then
      print_lib ${curr_lib_name} ${dll_code} ${dll_wdata} ${dll_rdata}
    fi

    tot_lib
  fi

  echo "Program/Module: ${pgm_name} Pid: ${1}"
  printf "  Code : %7d Kb\n" $(expr ${pgm_code} / 1024)
  if [ ${pgm_wdata} -gt 0 ] ; then
    printf "  RW   : %7d Kb\n" $(expr ${pgm_wdata} / 1024)
  fi
  if [ ${pgm_rdata} -gt 0 ] ; then
    printf "  RO   : %7d Kb\n" $(expr ${pgm_rdata} / 1024)
  fi
  if [ ${pgm_heap} -gt 0 ] ; then
    printf "  Heap : %7d Kb\n" $(expr ${pgm_heap} / 1024)
  fi
  if [ ${pgm_stack} -gt 0 ] ; then
    printf "  Stack: %7d Kb\n" $(expr ${pgm_stack} / 1024)
  fi
  if [ ${pgm_shm} -gt 0 ] ; then
    printf "  Shm  : %7d Kb\n" $(expr ${pgm_shm} / 1024)
  fi
  if [ ${pgm_rw_an} -gt 0 ] ; then
    printf "  RW An: %7d Kb\n" $(expr ${pgm_rw_an} / 1024)
  fi
  if [ ${pgm_ro_an} -gt 0 ] ; then
    printf "  RO An: %7d Kb\n" $(expr ${pgm_ro_an} / 1024)
  fi

  echo "Shared libraries:"
  printf "  Code : %7d Kb\n" $(expr ${dll_tot_code} / 1024)
  if [ ${dll_tot_wdata} -gt 0 ] ; then
    printf "  RW   : %7d Kb\n" $(expr ${dll_tot_wdata} / 1024)
  fi
  if [ ${dll_tot_rdata} -gt 0 ] ; then
    printf "  RO   : %7d Kb\n" $(expr ${dll_tot_rdata} / 1024)
  fi

  let "res_data = ${pgm_wdata} + ${pgm_heap} + ${pgm_stack} + ${pgm_rw_an} + ${dll_tot_wdata} + ${pgm_shm}"

  echo "Resident Data ${pgm_name}/${1}: $(expr ${res_data} / 1024) Kb"
}

usage ()
{

  if [ -n "$1" ] ; then
    echo
    echo "Error: $1"
  fi

  echo
  echo "USAGE:"
  echo
  echo `basename $0` "[-x] [-l] program|PID ..."
  echo
  exit
}

#Script Main

while getopts "xlh" op ; do
  case ${op} in
   x)
     VERBOSE=1
     ;;
   l)
     LIST_SHARED=1
     ;;
   h)
     usage
     ;;
   ?)
     usage "Invalid Option: ${op}"
     ;;
  esac
done

if [ ${OPTIND} -gt 1 ] ; then
  shift $(expr ${OPTIND} - 1)
fi

if [ $# -eq 0 ] ; then
  usage "Process list not given"
fi

if [ ${VERBOSE} -eq 1 ] ; then
  set -x
fi

while [ -n "${1}" ] ; do

  arg=${1##[0-9]*}

  if [ -z "${arg}" ] ; then

    if kill -n 0 ${1} 2>/dev/null ; then
      mem_usage_id ${1}
    else
      echo "Process ID ${1} not found"
    fi

  else

    pid=$(pidof ${1})

    if [ -z "${pid}" ] ; then
      echo "Program ${1} not running"
    else
      mem_usage_id ${pid}
    fi

  fi

  shift
done

