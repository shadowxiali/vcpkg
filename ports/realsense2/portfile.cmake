include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF v2.10.4
    SHA512 35580cd4ab65b85eb7fcebac3be629960993223437e3c44b0bcc2f7572d85231e822a922b2f5e22480fcc1edb9295ab2c5893794d638c2ab6faf49a9eea57603
    HEAD_REF development
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_CRT_LINKAGE)

set(BUILD_EXAMPLES OFF)
set(BUILD_GRAPHICAL_EXAMPLES OFF)
if("tools" IN_LIST FEATURES)
  set(BUILD_EXAMPLES ON)
  set(BUILD_GRAPHICAL_EXAMPLES ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        #Ungrouped Entries
        -DENFORCE_METADATA=ON
        # BUILD
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_WITH_OPENMP=OFF
        -DBUILD_WITH_STATIC_CRT=${BUILD_CRT_LINKAGE}
    OPTIONS_RELEASE
        -DBUILD_EXAMPLES=${BUILD_EXAMPLES}
        -DBUILD_GRAPHICAL_EXAMPLES=${BUILD_GRAPHICAL_EXAMPLES}
    OPTIONS_DEBUG
        # BUILD
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GRAPHICAL_EXAMPLES=OFF
        # CMAKE
        "-DCMAKE_PDB_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        -DCMAKE_DEBUG_POSTFIX="_d"
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/realsense2)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(BUILD_EXAMPLES)
    file(GLOB EXEFILES_RELEASE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(GLOB EXEFILES_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(COPY ${EXEFILES_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/realsense2)
    file(REMOVE ${EXEFILES_RELEASE} ${EXEFILES_DEBUG})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/realsense2)
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/realsense2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/realsense2/COPYING ${CURRENT_PACKAGES_DIR}/share/realsense2/copyright)
