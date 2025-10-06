/// Wrapper for API responses that includes metadata about the data source
class DataResponse<T> {
  
  const DataResponse({
    required this.data,
    required this.isFromMockData,
    this.errorMessage,
  });
  
  factory DataResponse.fromApi(T data) {
    return DataResponse(
      data: data,
      isFromMockData: false,
    );
  }
  
  factory DataResponse.fromMock(T data, {String? errorMessage}) {
    return DataResponse(
      data: data,
      isFromMockData: true,
      errorMessage: errorMessage,
    );
  }
  final T data;
  final bool isFromMockData;
  final String? errorMessage;
}