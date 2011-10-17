class mysql {
  case $operatingsystem {
    default: { 
      import 'defines/*.pp' 
      import 'classes/*.pp' 
    }
  }
}
