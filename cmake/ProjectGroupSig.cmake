include(ExternalProject)
include(GNUInstallDirs)

if (CRYPTO_EXTENSION)
    ExternalProject_Add(GroupSigLib
        PREFIX ${CMAKE_SOURCE_DIR}/deps
        DOWNLOAD_NAME group_sig_lib.tgz
        DOWNLOAD_NO_PROGRESS 1
        GIT_REPOSITORY https://github.com/FISCO-BCOS/Group-Signature.git
        GIT_TAG c22e461673f1b4f94e5a6240c28286eee0a9f60c
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        -DCMAKE_POSITION_INDEPENDENT_CODE=on
        LOG_CONFIGURE 1
        BUILD_IN_SOURCE 1
        LOG_CONFIGURE 1
    )

    ExternalProject_Get_Property(GroupSigLib SOURCE_DIR)
    set(LIB_SUFFIX .a)
    set(DEPS_INCLUDE_DIR ${SOURCE_DIR}/deps/include)
    file(MAKE_DIRECTORY ${DEPS_INCLUDE_DIR}) 

    find_library(GMP_LIBRARIES NAMES "libgmp.a")
    find_path(GMP_INCLUDE_DIR "gmp.h")
    add_library(Gmp UNKNOWN IMPORTED)
    set_property(TARGET Gmp PROPERTY IMPORTED_LOCATION ${GMP_LIBRARIES})
    set_property(TARGET Gmp PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${GMP_INCLUDE_DIR})

    add_library(Pbc STATIC IMPORTED)
    set_property(TARGET Pbc PROPERTY IMPORTED_LOCATION ${SOURCE_DIR}/deps/lib/libpbc${LIB_SUFFIX})
    set_property(TARGET Pbc PROPERTY INTERFACE_LINK_LIBRARIES Gmp)
    set_property(TARGET Pbc PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${DEPS_INCLUDE_DIR} ${GMP_INCLUDE_DIR})
    add_dependencies(Pbc GroupSigLib)

    add_library(PbcSig STATIC IMPORTED)
    set_property(TARGET PbcSig PROPERTY IMPORTED_LOCATION ${SOURCE_DIR}/deps/lib/libpbc_sig${LIB_SUFFIX})
    set_property(TARGET PbcSig PROPERTY INTERFACE_LINK_LIBRARIES Pbc)
    set_property(TARGET PbcSig PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${DEPS_INCLUDE_DIR})
    add_dependencies(PbcSig GroupSigLib)

    add_library(GroupSig STATIC IMPORTED)
    set(GROUPSIG_LIBRARY ${CMAKE_SOURCE_DIR}/deps/lib/libgroup_sig${LIB_SUFFIX})
    set(GROUPSIG_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/deps/include)
    file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/deps/lib)  # Must exist.
    file(MAKE_DIRECTORY ${GROUPSIG_INCLUDE_DIR})  # Must exist.
    set_property(TARGET GroupSig PROPERTY IMPORTED_LOCATION ${GROUPSIG_LIBRARY})
    set_property(TARGET GroupSig PROPERTY INTERFACE_LINK_LIBRARIES PbcSig Pbc Gmp)
    set_property(TARGET GroupSig PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${GROUPSIG_INCLUDE_DIR} ${DEPS_INCLUDE_DIR})
    add_dependencies(GroupSig GroupSigLib)
    unset(SOURCE_DIR)
endif ()
