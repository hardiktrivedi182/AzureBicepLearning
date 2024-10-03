// Parameters
param apimName string
param apimPublisherEmail string
param apimPublisherName string
param apiName string = 'default-response-stub-api'
param apiDisplayName string = 'Default Response Stub API'
param apiPath string = 'default-response-stub'
param apiVersion string = 'v1'

// Variables
var apiServiceUrl = 'https://dummy-service-url'  // You can replace this with your actual backend service if needed

// API Management instance
resource apim 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apimName
  location: resourceGroup().location
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  properties: {
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
  }
}

// API definition
resource api 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  parent: apim
  name: apiName
  properties: {
    displayName: apiDisplayName
    path: apiPath
    serviceUrl: apiServiceUrl // Using a placeholder service URL
    protocols: [
      'https'
    ]
  }
}

// API Operation
resource apiOperation 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: api
  name: 'get-details'
  properties: {
    displayName: 'Get Details'
    method: 'GET'
    urlTemplate: '/get-details'
    request: {
      description: 'Request to get default response details'
    }
    responses: [
      {
        description: '200 OK'
        statusCode: 200
        representations: [
          {
            contentType: 'application/json'
          }
        ]
      }
    ]
  }
}

// API Policy for returning default response (stub)
resource apiPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apiOperation
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: '''
      <inbound>
          <base />
          <!-- Define a response body for the API operation -->
          <set-body>@{
            {
              "ProjectCode": "1234",
              "EntityName": "Entity1",
              "RIName": "AuditRI",
              "SubSector": "SubSector1",
              "PIEReason": "",
              "IsHighRiskAudit": false
            }
          }</set-body>
          <!-- Set the response content type to JSON -->
          <set-header name="Content-Type" exists-action="override">
              <value>application/json</value>
          </set-header>
      </inbound>
      <backend>
          <base />
      </backend>
      <outbound>
          <base />
      </outbound>
      <on-error>
          <base />
      </on-error>
    '''
  }
}
