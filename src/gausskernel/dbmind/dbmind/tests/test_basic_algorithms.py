# Copyright (c) 2020 Huawei Technologies Co.,Ltd.
#
# openGauss is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
#
#          http://license.coscl.org.cn/MulanPSL2
#
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
from dbmind.common.algorithm import basic

s1 = (1, 3, 3, 4, 10, 11, 15, 17, 20, 20, 20, 21, 21, 22)
s2 = (1, 2, 2, 2, 3)


def test_binary_search():
    for s in (s1, s2):
        for v in s:
            assert s[basic.binary_search(s, v)] == v


def test_binary_search_left():
    assert basic.binary_search_left(s1, 1) == 0
    assert basic.binary_search_left(s1, 20) == 8
    assert basic.binary_search_left(s1, 22) == len(s1) - 1
    assert basic.binary_search_left(s1, 0) == -1
    assert basic.binary_search_left(s1, 2222) == -1

    assert basic.how_many_lesser_elements(s1, 0) == 0
    assert basic.how_many_lesser_elements(s1, 1) == 0
    assert basic.how_many_lesser_elements(s1, 3) == 1
    assert basic.how_many_lesser_elements(s1, 4) == 3
    assert basic.how_many_lesser_elements(s1, 10) == 4
    assert basic.how_many_lesser_elements(s1, 100) == len(s1)

    start = basic.how_many_lesser_elements(s1, 17)
    end = basic.how_many_lesser_elements(s1, 22)
    length = end - start + 1
    assert length == 7

    assert basic.how_many_lesser_elements([1], 0) == 0
    assert basic.binary_search_left([1], 0) == -1

    assert basic.binary_search_leftmost([1, 2, 2, 2, 2, 4, 5], 3) == 5
    assert basic.how_many_larger_elements([1, 2, 4, 5], 3) == 2
    assert basic.how_many_larger_elements([1, 2, 3, 4, 5], 3) == 2
    assert basic.how_many_larger_elements([1, 2, 4, 5], 5) == 0
    assert basic.how_many_larger_elements([1, 2, 4, 5, 5, 5], 5) == 0
    assert basic.how_many_larger_elements([1, 2, 4, 5, 5, 5], -1) == 6


def test_hash_functions():
    str1 = 'abcdefg000\n abc'
    str2 = ''
    str3 = '0123123   aaaa'
    assert basic.dek_hash(str1) == 1663651373
    assert basic.dek_hash(str2) == 0
    assert basic.dek_hash(str3) == 1274746930
    assert basic.djb_hash(str1) == 981132161
    assert basic.djb_hash(str2) == 5381
    assert basic.djb_hash(str3) == 4269394821

