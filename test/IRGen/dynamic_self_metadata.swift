// RUN: %target-swift-frontend %s -emit-ir | FileCheck %s

// REQUIRES: CPU=x86_64

// FIXME: Not a SIL test because we can't parse dynamic Self in SIL.
// <rdar://problem/16931299>

// CHECK: [[TYPE:%.+]] = type <{ [8 x i8] }>

@inline(never) func id<T>(t: T) -> T {
  return t
}
// CHECK-LABEL: define hidden void @_TF21dynamic_self_metadata2idurFq_q_

class C {
  class func fromMetatype() -> Self? { return nil }
  // CHECK-LABEL: define hidden i64 @_TZFC21dynamic_self_metadata1C12fromMetatypefMS0_FT_GSqDS0__(%swift.type*)
  // CHECK: [[ALLOCA:%.+]] = alloca [[TYPE]], align 8
  // CHECK: [[CAST1:%.+]] = bitcast [[TYPE]]* [[ALLOCA]] to i64*
  // CHECK: store i64 0, i64* [[CAST1]], align 8
  // CHECK: [[CAST2:%.+]] = bitcast [[TYPE]]* [[ALLOCA]] to i64*
  // CHECK: [[LOAD:%.+]] = load i64, i64* [[CAST2]], align 8
  // CHECK: ret i64 [[LOAD]]

  func fromInstance() -> Self? { return nil }
  // CHECK-LABEL: define hidden i64 @_TFC21dynamic_self_metadata1C12fromInstancefS0_FT_GSqDS0__(%C21dynamic_self_metadata1C*)
  // CHECK: [[ALLOCA:%.+]] = alloca [[TYPE]], align 8
  // CHECK: [[CAST1:%.+]] = bitcast [[TYPE]]* [[ALLOCA]] to i64*
  // CHECK: store i64 0, i64* [[CAST1]], align 8
  // CHECK: [[CAST2:%.+]] = bitcast [[TYPE]]* [[ALLOCA]] to i64*
  // CHECK: [[LOAD:%.+]] = load i64, i64* [[CAST2]], align 8
  // CHECK: ret i64 [[LOAD]]

  func dynamicSelfArgument() -> Self? {
    return id(nil)
  }
  // CHECK-LABEL: define hidden i64 @_TFC21dynamic_self_metadata1C19dynamicSelfArgumentfS0_FT_GSqDS0__(%C21dynamic_self_metadata1C*)
  // CHECK: [[CAST1:%.+]] = bitcast %C21dynamic_self_metadata1C* %0 to [[METATYPE:%.+]]
  // CHECK: [[TYPE1:%.+]] = call %swift.type* @swift_getObjectType([[METATYPE]] [[CAST1]])
  // CHECK: [[CAST2:%.+]] = bitcast %swift.type* [[TYPE1]] to i8*
  // CHECK: [[TYPE2:%.+]] = call %swift.type* @swift_getGenericMetadata1(%swift.type_pattern* @_TMPSq, i8* [[CAST2]])
  // CHECK: call void @_TF21dynamic_self_metadata2idurFq_q_({{.*}}, %swift.type* [[TYPE2]])
}
