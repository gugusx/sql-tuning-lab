-- View: vw_shipment_item_reports
-- Description: Aggregated shipment report view combining warehouse, courier, and billing data
CREATE OR REPLACE VIEW vw_shipment_item_reports AS
SELECT 
    s.id AS shipment_id,
    c.id AS courier_id,
    c.name AS courier_name,
    v.id AS vendor_id,
    v.name AS vendor_name,
    v.status AS vendor_status,
    hub.id AS distribution_hub_id,
    hub.name AS distribution_hub_name,
    m.manifest_type,
    m.file_reference,
    s.tracking_number,
    s.waybill_number,
    s.shipping_period,
    s.service_type,
    s.currency_code,
    s.declared_value,
    s.recipient_name_masked,
    s.origin_warehouse,
    s.recipient_name,
    s.fulfillment_status,
    s.dispatch_date,
    s.status_code,
    s.clearance_code,
    s.failure_code,
    s.status_description,
    s.delivery_date,
    s.retry_attempt_count,
    manifest_item.item_note AS package_description,
    v.vendor_code,
    s.current_state
FROM shipments s
    LEFT JOIN couriers c ON s.courier_id = c.id
    LEFT JOIN manifests m ON s.manifest_id = m.id
    LEFT JOIN vendor_accounts va ON m.vendor_id = va.vendor_id
    LEFT JOIN recipient_profiles rp ON s.recipient_profile_id = rp.id
    LEFT JOIN distribution_hubs hub ON rp.hub_id = hub.id OR m.hub_id = hub.id
    LEFT JOIN clients cl ON rp.client_id = cl.id
    LEFT JOIN vendors v ON cl.vendor_id = v.id OR m.vendor_id = v.id
    LEFT JOIN cargo_items manifest_item ON s.waybill_number = manifest_item.waybill_code AND manifest_item.recipient_profile_id = rp.id
    LEFT JOIN manifests m_item ON manifest_item.manifest_id = m_item.id
ORDER BY s.id DESC;


-- Query: Get Vendor Shipment Report by Date Range
SELECT
    vendor_code,
    shipment_id,
    waybill_number,
    tracking_number,
    package_description,
    service_type,
    manifest_type,
    file_reference,
    currency_code,
    declared_value,
    recipient_name_masked,
    courier_name,
    origin_warehouse,
    recipient_name,
    fulfillment_status,
    dispatch_date,
    clearance_code,
    status_code,
    status_description,
    failure_code
FROM
    vw_shipment_item_reports
WHERE
    dispatch_date >= {{start_date}} 
    AND dispatch_date <= {{end_date}}
    AND vendor_name = {{vendor_name}};
